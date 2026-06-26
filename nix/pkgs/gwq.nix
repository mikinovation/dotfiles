{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule rec {
  pname = "gwq";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    rev = "v${version}";
    hash = "sha256-MfCYFbODWnfPxx+6sLlcMT6tqghgILHB13+ccYqVjBA=";
  };

  vendorHash = "sha256-4K01Xf1EXl/NVX1loQ76l1bW8QglBAQdvlZSo7J4NPI=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/d-kuro/gwq/internal/cmd.version=v${version}"
  ];

  # Discovery tests shell out to git.
  nativeCheckInputs = [ git ];

  # Tests create a config dir under $HOME, which is unset in the sandbox.
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  meta = {
    description = "Git worktree manager with ghq-like structured layout";
    homepage = "https://github.com/d-kuro/gwq";
    license = lib.licenses.asl20;
    mainProgram = "gwq";
  };
}
