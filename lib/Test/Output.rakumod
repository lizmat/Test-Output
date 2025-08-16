use Test;
use Trap:ver<0.0.5+>:auth<zef:lizmat>;

#- helper subroutines ----------------------------------------------------------------------
my sub test($output, &tester, &code, Any:D $expected, Str:D $message = "") {
    code();
    tester $output.text, $expected, $message
}

my sub silent($output, &code, Str:D $message = "") {
    code();
    is-deeply $output.silent, True, $message
}

my sub output($output, &code --> Str:D) {
    code();
    $output.text
}

#- tester subs -----------------------------------------------------------------
my $verbosity;

my sub test-output-verbosity(:$on, :$off) {
    $verbosity =  $_ with $on;
    $verbosity = !$_ with $off;
}

my sub output-is(|c) is test-assertion {
    test Trap(my $*OUT, my $*ERR, |(:tee<OUT> if $verbosity)), &is, |c
}
my sub stdout-is(|c) is test-assertion {
    test Trap(my $*OUT, |(:tee<OUT> if $verbosity)), &is, |c
}
my sub stderr-is(|c) is test-assertion {
    test Trap(my $*ERR, |(:tee<ERR> if $verbosity)), &is, |c
}

my sub output-like(|c) is test-assertion {
    test Trap(my $*OUT, my $*ERR, |(:tee<OUT> if $verbosity)), &like, |c
}
my sub stdout-like(|c) is test-assertion {
    test Trap(my $*OUT, |(:tee<OUT> if $verbosity)), &like, |c
}
my sub stderr-like(|c) is test-assertion {
    test Trap(my $*ERR, |(:tee<ERR> if $verbosity)), &like, |c
}

#- silent subs -----------------------------------------------------------------

my sub no-output(&code, Str:D $message = "") is test-assertion {
    silent Trap(my $*OUT, my $*ERR), &code, $message
}
my sub no-stdout(&code, Str:D $message = "") is test-assertion {
    silent Trap(my $*OUT), &code, $message
}
my sub no-stderr(&code, Str:D $message = "") is test-assertion {
    silent Trap(my $*ERR), &code, $message
}

#- output subs -----------------------------------------------------------------
my sub output-from(&code --> Str:D) { output Trap(my $*OUT, my $*ERR), &code }
my sub stdout-from(&code --> Str:D) { output Trap(my $*OUT          ), &code }
my sub stderr-from(&code --> Str:D) { output Trap(          my $*ERR), &code }

#- EXPORT ----------------------------------------------------------------------
my sub EXPORT(*@names) {
    Map.new: @names
      ?? @names.map: {
             if UNIT::{"&$_"}:exists {
                 UNIT::{"&$_"}:p
             }
             else {
                 my ($in,$out) = .split(':', 2);
                 if $out && UNIT::{"&$in"} -> &code {
                     Pair.new: "&$out", &code
                 }
             }
         }
      !! <
           no-output   no-stderr no-stdout
           output-from output-is output-like
           stderr-from stderr-is stderr-like
           stdout-from stdout-is stdout-like
           test-output-verbosity
         >.map({  # UNCOVERABLE
             "&$_" => UNIT::{"&$_"}  # UNCOVERABLE
         }).Map
}

#- hack ------------------------------------------------------------------------
# To allow version fetching in test files
unit module Test::Output:ver<1.2>:auth<zef:raku-community-modules>;
