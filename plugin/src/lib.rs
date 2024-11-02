#[cfg(target_arch = "wasm32")]
use wasm_minimal_protocol::wasm_func;

pub mod model;
pub mod parser;

fn cbor_encode<T>(value: &T) -> Result<Vec<u8>, ciborium::ser::Error<std::io::Error>>
where
    T: serde::Serialize + ?Sized,
{
    let mut writer = Vec::new();
    ciborium::into_writer(value, &mut writer)?;
    Ok(writer)
}

#[cfg(target_arch = "wasm32")]
wasm_minimal_protocol::initiate_protocol!();

#[cfg_attr(target_arch = "wasm32", wasm_func)]
pub fn parse(diagram: &[u8]) -> Vec<u8> {
    let diagram: String = ciborium::from_reader(diagram).unwrap();
    let diagram = parser::parse(&diagram).unwrap();
    let diagram = cbor_encode(&diagram).unwrap();
    diagram
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        parse(&cbor_encode("class A").unwrap());
    }
}
