# typed: false
# frozen_string_literal: true

class Align < Formula
  desc "AOT-compiled, data-oriented programming language"
  homepage "https://github.com/sanohiro/align"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/sanohiro/align/releases/download/v0.1.0/alignc-macos-aarch64.tar.gz"
      sha256 "cdc8378b2147d929da6b4fae6853ad6cc4df98f3fffde66fc10a679e383ef712"
    end
  end

  depends_on "llvm@22"
  depends_on "openssl@3"
  depends_on "zstd"
  depends_on :macos

  def install
    libexec.install "alignc", "libalign_runtime.a"

    # OpenSSL is keg-only, and alignc links capability libraries through the system C linker.
    # The wrapper makes the Homebrew prefixes visible without baking a machine-specific path into
    # the compiler or requiring users to export LIBRARY_PATH themselves.
    (bin/"alignc").write <<~SH
      #!/bin/bash
      export LIBRARY_PATH="#{Formula["openssl@3"].opt_lib}:#{Formula["zstd"].opt_lib}${LIBRARY_PATH:+:$LIBRARY_PATH}"
      exec "#{libexec}/alignc" "$@"
    SH
    (bin/"alignc").chmod 0755
  end

  test do
    assert_match "alignc #{version}", shell_output("#{bin}/alignc --version")
  end
end
