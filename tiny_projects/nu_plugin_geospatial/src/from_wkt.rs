use crate::geometry::GeometryCustomValue;
use nu_plugin::{EngineInterface, EvaluatedCall, SimplePluginCommand};
use nu_protocol::{Category, Example, LabeledError, Signature, Type, Value};
use wkt::TryFromWkt;

use crate::GeoSpatialPlugin;

pub struct FromWkt;

impl SimplePluginCommand for FromWkt {
    type Plugin = GeoSpatialPlugin;

    fn name(&self) -> &str {
        "from wkt"
    }

    fn description(&self) -> &str {
        "Decodes wkt into a geospatial data type"
    }

    fn extra_description(&self) -> &str {
        "I'll tell you later"
    }

    fn signature(&self) -> Signature {
        Signature::build(self.name())
            .input_output_type(Type::String, Type::custom("GeometryCustomValue"))
            .category(Category::Experimental)
    }

    fn search_terms(&self) -> Vec<&str> {
        vec!["geo", "geospatial"]
    }

    fn examples(&self) -> Vec<Example<'_>> {
        Vec::new()
    }

    fn run(
        &self,
        _plugin: &GeoSpatialPlugin,
        _engine: &EngineInterface,
        _call: &EvaluatedCall,
        input: &Value,
    ) -> Result<Value, LabeledError> {
        let Value::String { val, internal_span, .. } = input else {
            return Err(LabeledError::new("Must input a string type"));
        };

        let geometry = geo::Geometry::try_from_wkt_str(val)
            .map_err(|_e| LabeledError::new("Unable to convert wkt"))?;

        Ok(GeometryCustomValue { geometry }.into_value(*internal_span))
    }
}
