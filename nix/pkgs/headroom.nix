{
  lib,
  python3Packages,
  fetchurl,
  autoPatchelfHook,
  stdenv,
}:

python3Packages.buildPythonApplication rec {
  pname = "headroom-ai";
  version = "0.36.5";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/15/c9/650195df8133b0f2ae5156bd9780fd70e17d8cead361016983e72d629697/headroom_ai-${version}-cp310-abi3-manylinux_2_28_x86_64.whl";
    hash = "sha256-VpVLds0QtTEgYXJedHBXVZikveP6f4D3fYKginH86ug=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dependencies = with python3Packages; [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    ast-grep-cli
    pyyaml
    tomlkit

    fastapi
    uvicorn
    orjson
    httpx
    h2
    openai
    mcp
    magika
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog
    sqlite-vec
  ];

  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [ "headroom" ];

  meta = {
    description = "Context compression layer for AI agents";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    platforms = [ "x86_64-linux" ];
  };
}
