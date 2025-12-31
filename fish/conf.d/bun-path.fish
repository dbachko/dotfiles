# Bun's official installer uses ~/.bun/bin. Add it if present.

if test -d "$HOME/.bun/bin"
  set -gx BUN_INSTALL "$HOME/.bun"
  fish_add_path --global "$HOME/.bun/bin"
end

