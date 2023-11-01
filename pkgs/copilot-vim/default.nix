{ fetchFromGitHub, buildVimPlugin }:
{
  copilot-vim = buildVimPlugin {
    pname = "copilot.vim";
    version = "1.8.3";

    src = fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "9e869d29e62e36b7eb6fb238a4ca6a6237e7d78b";
      sha256 = "0jzk1hd8kvh8bswdzbnbjn62r19l4j5klyni7gxbhsgbshfa3v87";
    };

    meta.homepage = "https://github.com/github/copilot.vim/";
  };
}
