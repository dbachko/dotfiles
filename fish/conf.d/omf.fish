# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# OMF sets these paths globally, which prevents Fish 4.x from falling back to
# its bundled autoload dirs. Keep stock helpers/completions available before OMF
# starts loading git-aware themes and packages.
if set -q __fish_data_dir
    contains -- "$__fish_data_dir/functions" $fish_function_path
        or set -a fish_function_path "$__fish_data_dir/functions"

    set -l fish_stock_completions "$__fish_data_dir/completions"
    if not contains -- "$fish_stock_completions" $fish_complete_path
        if set -q __fish_cache_dir
            and set -l generated_index (contains -i -- "$__fish_cache_dir/generated_completions" $fish_complete_path)
            set fish_complete_path \
                $fish_complete_path[1..(math $generated_index - 1)] \
                "$fish_stock_completions" \
                $fish_complete_path[$generated_index..-1]
        else
            set -a fish_complete_path "$fish_stock_completions"
        end
    end
end

# Load Oh My Fish configuration.
if test -f $OMF_PATH/init.fish
    source $OMF_PATH/init.fish
end
