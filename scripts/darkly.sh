#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

main()
{
  # set current directory variable
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # set configuration option variables
  show_powerline=$(get_tmux_option "@darkly-show-powerline" true)
  show_flags=$(get_tmux_option "@darkly-show-flags" false)
  show_left_icon=$(get_tmux_option "@darkly-show-left-icon" lambda)
  show_left_sep=$(get_tmux_option "@darkly-show-left-sep" )
  show_right_sep=$(get_tmux_option "@darkly-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@darkly-border-contrast" false)
  show_refresh=$(get_tmux_option "@darkly-refresh-rate" 5)

  # darkly Color Pallette
  white='#f8f8f2'
  gray='#444444'
  dark_gray='#323232'
  #light_purple='#bd93f9'
  #dark_purple='#6272a4'
  #cyan='#8be9fd'
  green='#4bc98a'
  #orange='#ffb86c'
  #red='#ff5555'
  #pink='#ff79c6'
  #yellow='#f1fa8c'


  # Handle left icon configuration
  case $show_left_icon in
      lambda)
          left_icon="Ⲗ ";;
      session)
          left_icon="#S ";;
      window)
	  left_icon="#W ";;
      *)
          left_icon=$show_left_icon;;
  esac

  # Handle powerline option
  if $show_powerline; then
      right_sep="$show_right_sep"
      left_sep="$show_left_sep"
  fi

  # start weather script in background
  if $show_weather; then
    $current_dir/sleep_weather.sh $show_fahrenheit $show_location &
  fi

  # Set timezone unless hidden by configuration
  case $show_timezone in
      false)
          timezone="";;
      true)
          timezone="#(date +%Z)";;
  esac

  case $show_flags in
    false)
      flags=""
      current_flags="";;
    true)
      flags="#{?window_flags,#[fg=${dark_purple}]#{window_flags},}"
      current_flags="#{?window_flags,#[fg=${light_purple}]#{window_flags},}"
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${light_purple}"
  else
    tmux set-option -g pane-active-border-style "fg=${dark_purple}"
  fi
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"

  # wait unit data/weather.txt exists just to avoid errors
  # this should almost never need to wait unless something unexpected occurs
  while $show_weather && [ ! -f $current_dir/../data/weather.txt ]; do
      sleep 0.01
  done

  # Powerline Configuration
  if $show_powerline; then

      tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${green},bg=${gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
      tmux set-option -g  status-right ""
      powerbg=${gray}
      tmux set-window-option -g window-status-current-format "#[fg=${gray},bg=${dark_purple}]${left_sep}#[fg=${white},bg=${dark_purple}] #I #W${current_flags} #[fg=${dark_purple},bg=${gray}]${left_sep}"

  # Non Powerline Configuration
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
    tmux set-option -g  status-right ""
    tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${dark_purple}] #I #W${current_flags} "

  fi

  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W${flags}"
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
