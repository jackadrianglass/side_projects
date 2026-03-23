use crate::geometry::GeometryCustomValue;
use geo_traits::to_geo::ToGeoGeometry;
use nu_plugin::{EngineInterface, EvaluatedCall, SimplePluginCommand};
use nu_protocol::{Category, Example, LabeledError, Signature, Type, Value};
use wkb::reader::read_wkb;

use crate::GeoSpatialPlugin;

pub struct FromWkb;

impl SimplePluginCommand for FromWkb {
    type Plugin = GeoSpatialPlugin;

    fn name(&self) -> &str {
        "from wkb"
    }

    fn description(&self) -> &str {
        "Decodes wkb into a geospatial data type"
    }

    fn extra_description(&self) -> &str {
        "I'll tell you later"
    }

    fn signature(&self) -> Signature {
        Signature::build(self.name())
            .input_output_type(Type::Binary, Type::custom("GeometryCustomValue"))
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
        let Value::Binary { val, internal_span, .. } = input else {
            return Err(LabeledError::new("Must input a binary type"));
        };

        let geometry = read_wkb(val)
            .map_err(|_e| LabeledError::new("Unable to convert wkb"))?
            .to_geometry();

        Ok(GeometryCustomValue { geometry }.into_value(*internal_span))
    }
}
