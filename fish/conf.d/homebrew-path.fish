# Ensure Homebrew is on PATH for all fish sessions.
# Works for both Apple Silicon (/opt/homebrew) and Intel (/usr/local).

if type -q brew
  set -l brew_bin (command -v brew)
  set -l brew_prefix (dirname (dirname $brew_bin))

  if test -d "$brew_prefix/bin"
    fish_add_path --global "$brew_prefix/bin"
  end

  if test -d "$brew_prefix/sbin"
    fish_add_path --global "$brew_prefix/sbin"
  end
end

