del() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: del <file-or-directory> [...]"
        return 1
    fi

    for target in "$@"; do
        if [[ ! -e "$target" && ! -L "$target" ]]; then
            echo "Not found: $target"
            continue
        fi

        if [[ -d "$target" ]]; then
            echo "Delete directory and all contents:"
        else
            echo "Delete:"
        fi

        echo "  $target"
        read -r "confirm?Confirm? [y/N] "

        if [[ "$confirm" != [yY] ]]; then
            echo "Cancelled."
            continue
        fi

        echo "Deleting..."

        # Fast path: normal deletion.
        rm -rf -- "$target" 2>/dev/null

        # Completely gone.
        if [[ ! -e "$target" && ! -L "$target" ]]; then
            echo "✓ Deleted successfully."
            continue
        fi

        # Empty directory remained.
        if [[ -d "$target" ]] && ! find "$target" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
            if rmdir -- "$target" 2>/dev/null; then
                echo "✓ Deleted successfully."
            else
                echo "✗ Deletion failed: empty directory remains."
            fi
            continue
        fi

        # Something remains. Check for immutable files only now.
        echo "Standard deletion failed."
        echo "Checking for immutable files..."

        if find "$target" -flags uchg -print -quit 2>/dev/null | grep -q .; then
            echo "Immutable files found."
            echo "Removing immutable flags..."

            if chflags -R nouchg "$target" 2>/dev/null; then
                echo "Retrying deletion..."

                rm -rf -- "$target" 2>/dev/null

                if [[ ! -e "$target" && ! -L "$target" ]]; then
                    echo "✓ Deleted successfully."
                elif [[ -d "$target" ]] &&
                     ! find "$target" -mindepth 1 -print -quit 2>/dev/null | grep -q . &&
                     rmdir -- "$target" 2>/dev/null; then
                    echo "✓ Deleted successfully."
                else
                    echo "✗ Deletion failed: target still exists."
                fi
            else
                echo "✗ Failed to remove immutable flags."
            fi
        else
            echo "✗ Deletion failed: no immutable files found."
        fi
    done
}
