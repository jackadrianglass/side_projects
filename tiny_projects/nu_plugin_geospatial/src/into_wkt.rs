use crate::geometry::GeometryCustomValue;
use nu_plugin::{EngineInterface, EvaluatedCall, SimplePluginCommand};
use nu_protocol::{Category, Example, LabeledError, Signature, Type, Value};
use wkt::ToWkt;

use crate::GeoSpatialPlugin;

pub struct IntoWkt;

impl SimplePluginCommand for IntoWkt {
    type Plugin = GeoSpatialPlugin;

    fn name(&self) -> &str {
        "into wkt"
    }

    fn description(&self) -> &str {
        "Encodes a geometry into its wkb representation"
    }

    fn extra_description(&self) -> &str {
        "I'll tell you later"
    }

    fn signature(&self) -> Signature {
        Signature::build(self.name())
            .input_output_type(Type::custom("GeometryCustomValue"), Type::String)
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
        call: &EvaluatedCall,
        input: &Value,
    ) -> Result<Value, LabeledError> {
        let GeometryCustomValue { geometry } = GeometryCustomValue::try_from_value(input)?;

        Ok(Value::string(geometry.wkt_string(), call.head))
    }
}
