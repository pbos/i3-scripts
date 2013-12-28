#!/usr/bin/env perl
# This workspace switcher uses a separate set (1..10) of workspaces per monitor
# output. It also toggles workspace similar to workspace_back_and_forth yes, but
# per output.
#
# Bindings MUST NOT conflict with .i3/config (remove bindsyms to $mod+0..9).
# The script also by default assumes that you use Super_L (Left Windows key) as
# modifier (since that's what I use). To change it, change ModKeyMask below.

use strict;
use warnings;

use constant {
# ModKeyMask => (1 << 3),  # Alt_L
  ModKeyMask => (1 << 6),  # Super_L
  ShiftMask  => (1 << 0),  # Shift
};

# Set up i3 IPC.
use AnyEvent::I3;
i3->connect;

# Set up X11 keybindings.
use X11::Protocol;
my $x = X11::Protocol->new;
my $mask = $x->pack_event_mask('KeyPress');
$x->ChangeWindowAttributes($x->root, event_mask => $mask);
$x->event_handler('queue');

# Register $mod (+ shift) + 0..9.
for my $i (0 .. 9) {
  $x->GrabKey(10 + $i, ModKeyMask, $x->root, 1, 'Asynchronous', 'Asynchronous');
  $x->GrabKey(10 + $i, ModKeyMask | ShiftMask, $x->root, 1, 'Asynchronous', 'Asynchronous');
}

# Find current output.
sub current_output() {
  my $outputs = i3->get_outputs->recv;
  my $workspaces = i3->get_workspaces->recv;
  my $output_name;
  # Find currently focused workspace, its output is the current one.
  foreach my $workspace (@$workspaces) {
    $output_name = @$workspace{'output'} if @$workspace{'focused'};
  }

  # Map name back to output index.
  for my $i (0 .. @{$outputs}-1) {
    my $output = @$outputs[$i];
    return $i + 1 if @$output{'name'} eq $output_name;
  }
}

# Main loop.
my %prev_workspace = ();
my %current_workspace = ();
for (;;) {
  my %event = $x->next_event;
  next if $event{name} ne 'KeyPress';
  next if $event{'detail'} < 10 || $event{'detail'} >= 20;
  # TODO(pbos): Move if shift is pressed. (-> need to listen to that as well)

  my $output = current_output();
  my $workspace = $event{detail} - 9;
  my $move = ($event{state} & ShiftMask);

  # Initialize history if required for this output.
  $prev_workspace{$output} ||= $workspace;
  $current_workspace{$output} ||= $workspace;

  # Toggle workspace on same output
  if ($move == 0 && $workspace == $current_workspace{$output}) {
    $workspace = $prev_workspace{$output};
  }

  my $workspace_name = $workspace . ' [' . $output . ']';
  i3->command(($move != 0 ? "move container to" : "") . "workspace " . $workspace_name)->recv;

  # Don't update history when moving containers.
  next if $move != 0;

  $prev_workspace{$output} = $current_workspace{$output};
  $current_workspace{$output} = $workspace;
}
