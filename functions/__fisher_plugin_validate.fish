function __fisher_plugin_validate -a plugin
    if test -z "$plugin"
        return 1
    end

    if set -q argv[2]
        printf "%s\n" "$argv"
        return 1
    end

    switch "$plugin"
        case ..\*
            printf "%s\n" "../"
            return 1

        case . ./\* /\*
            if test ! -e "$plugin"
                printf "%s\n" $plugin
                return 1
            end

            set plugin (
                switch "$plugin"
                    case /\*
                        printf "%s\n" $plugin

                    case \*
                        printf "$PWD/%s/%s" (dirname "$plugin") (basename "$plugin")

                end | sed -E 's|[./]*$||; s|/([\./])/+|/|g'
                )

            printf "%s\n" $plugin

            __fisher_plugin_validate (basename $plugin) > /dev/null

        case \*
            set -l id "[A-Za-z0-9._-]"

            if not printf "%s\n" "$plugin" | grep -qE "^(($id+)[:/]*)*\$"
                printf "%s\n" "$plugin"
                return 1
            end

            printf "%s\n" "$plugin" | sed -E "
                    s|^gh[:/]+|https://github.com/|
                    s|^gl[:/]+|https://gitlab.com/|
                    s|^bb[:/]+|https://bitbucket.org/|
                    s|^omf[:/]+|https://github.com/oh-my-fish/|
                    s|^($id+)/($id+)\$|https://github.com/\1/\2|
                    s|^(gist\.github\.com.*)|https://\1|
                    s|^http(s?)[:/]*|http\1://|
                    s|https://github((.com)?/)?|https://github.com/|
                    s|/*(\.git/*)*\$||g" | tr "[A-Z]" "[a-z]"
    end
end
