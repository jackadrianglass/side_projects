const toggle = document.getElementById('site-tree-toggle');
const dropdown = document.getElementById('site-tree-dropdown');

if (toggle && dropdown) {
  toggle.addEventListener('click', function (e) {
    e.stopPropagation();
    dropdown.classList.toggle('is-open');
  });

  document.addEventListener('click', function (e) {
    if (!dropdown.contains(e.target)) {
      dropdown.classList.remove('is-open');
    }
  });
}
