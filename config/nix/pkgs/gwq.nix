{ lib, buildGoModule, fetchFromGitHub, installShellFiles, git, tmux }:

buildGoModule rec {
  pname = "gwq";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;

  subPackages = [ "cmd/gwq" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd gwq \
      --bash <($out/bin/gwq completion bash) \
      --zsh <($out/bin/gwq completion zsh) \
      --fish <($out/bin/gwq completion fish)
  '';

  meta = with lib; {
    description = "Git worktree manager with fuzzy finder";
    homepage = "https://github.com/d-kuro/gwq";
    license = licenses.mit;
    mainProgram = "gwq";
  };
}
