(require '[clojure.string :as s])

(defn transpose [list_of_lists]
  ;; This was really confusing so I asked an LLM what the frick it does
  ;; 1. `apply` takes the last argument which is a collection and applies each element to the function provided
  ;;    e.g. (apply mapv vector [[1 2] [3 4]]) becomes (mapv vector [1 2] [3 4])
  ;; 2. `mapv` (and `map`) applies the function to the elements in the same position of each
  ;;    collection when provided more than one
  ;;    e.g. (mapv vector [1 2] [3 4]) -> (vector 1 3) (vector 2 4)
  ;; 3. `vector` constructs a vector. This one ain't all that crazy
  (apply mapv vector list_of_lists)
  )

;; It turns out that the padding is defined in the instructions so one has to preserve the spacing there
(defn pad-left [target-length value]
  (let [len (count value)
        padding (- target-length len)
        ]
    (if (= 0 padding) value
      (str (apply str (repeat padding " ")) value)
      )
    )
  )

(defn max-len [lst]
  (apply max (map count lst))
  )

(defn split-last [values]
  ;; There's no native pattern matching for this kind of thing (unlike the Haskell `scon` operator)
  ;; so the LLM recommended this kind of pattern
  [(butlast values) (last values)]
  )

(defn parse-op [in-op-str]
  (let [op-str (s/trim in-op-str)]
  ;; Kind of neat that you can just return operators in clojure
  (if (= op-str "*") *
    (if (= op-str "+") +
      ;; todo: Would like to see if there's like a result type or something. Not a fan of exceptions
      (throw (Exception. "Unknown operator"))
      )
    ))
  )

;; This one is pretty simple once you get to here
;; - Get the last element which is the operator
;; - Parse numbers from the other elements
;; - Apply the operator to a fold operation (though they call it `reduce` in clojure)
(defn compute-instructions-part1 [inst]
  (let [
        [elems op-str] (split-last inst)
        op (parse-op op-str)
        ]
    (reduce op (mapv parse-long elems))
    )
  )

(defn find-blank-columns [lines]
  (let [r (take (max-len lines)(range))]
    (filter
      (fn [idx]
        (every?
          (fn [v] (= v \space ))
          (map (fn [l] (nth l idx)) lines)
          )
        )
      r
      )
    )
  )


;; I tried getting this to work but it ended up giving me back a list of things of characters.
;; That really messed with something and I couldn't get it to work
;;
;; ;; Splits the line at specific indexes and includes the remainder at the end
;; (defn split-line [line idxs]
;;   (let [[_ _ acc] (reduce
;;                     (fn [[line prev-idx acc] idx]
;;                       (let [[head tail] (split-at (- idx prev-idx) line)]
;;                         [
;;                          ;; split-at doesn't remove the index so one needs to also pop that value
;;                          (rest tail)
;;                          ;; since we're popping the whitespace, need to increment the index
;;                          (+ idx 1)
;;                          ;; and accumulate the values
;;                          (conj acc head)
;;                          ]
;;                         )
;;                       )
;;                     ;; Basically walking through the line and splitting at indices
;;                     [line 0 ""]
;;                     ;; Also add in the length of the line so that the end appears in the list
;;                     (conj idxs (count line))
;;                     )
;;         ]
;;     acc
;;     )
;;   )

;; I'm sad to say but I cheated and used an LLM to write this function
(defn split-line [line idxs]
  (let [starts (cons 0 (map inc idxs))
        ends (concat idxs [(count line)])]
    (mapv #(subs line %1 %2) starts ends)))

;; Kind of a weird one but it looks like another transpose
;; 
(defn compute-instructions-part2 [lines]
  (let [
        blank-cols (find-blank-columns lines)
        split-lines (mapv (fn [l] (split-line l blank-cols)) lines)
        insts (transpose split-lines)
        values (mapv
                 (fn [inst]
                   (let [
                         [elems op-str] (split-last inst)
                         op (parse-op op-str)
                         target-len (max-len elems)
                         values (mapv #(apply str %) (transpose elems))
                         ]
                     (reduce op (map parse-long (map s/trim values)))
                     )
                   )
                 insts
                 )
        tmp (println values)
        ]
        (reduce + values)
    )
  )


(defn -main [& args]
  (let [
        contents (slurp "day6.txt")
        ; contents (slurp "day6.txt")
        ; lines (map s/trim (s/split-lines contents))
        ; instructions-part1 (transpose (mapv (fn [v] (s/split v #"\s+")) lines))
        ; evaluated-part1 (mapv compute-instructions-part1 instructions-part1)
        ; part1-answer (println (reduce + evaluated-part1))
        _ (println contents)
        lines (s/split-lines contents)
        part2-answer (compute-instructions-part2 lines)
        ]
      (println part2-answer)
    )
  )

(-main)
