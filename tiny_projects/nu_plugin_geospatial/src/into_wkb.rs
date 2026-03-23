use crate::geometry::GeometryCustomValue;
use nu_plugin::{EngineInterface, EvaluatedCall, SimplePluginCommand};
use nu_protocol::{Category, Example, LabeledError, Signature, Type, Value};
use wkb::writer::WriteOptions;

use crate::GeoSpatialPlugin;

pub struct IntoWkb;

impl SimplePluginCommand for IntoWkb {
    type Plugin = GeoSpatialPlugin;

    fn name(&self) -> &str {
        "into wkb"
    }

    fn description(&self) -> &str {
        "Encodes a geometry into its wkb representation"
    }

    fn extra_description(&self) -> &str {
        "I'll tell you later"
    }

    fn signature(&self) -> Signature {
        Signature::build(self.name())
            .input_output_type(Type::custom("GeometryCustomValue"), Type::Binary)
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

        let mut buf = Vec::new();
        wkb::writer::write_geometry(&mut buf, &geometry, &WriteOptions::default())
            .map_err(|_e| LabeledError::new("Unable to serialize wkb"))?;

        Ok(Value::binary(buf, call.head))
    }
}
