package TRunner;

# ABSTRACT: Selenium on Plack with Dancer
use utf8;
use Dancer ':syntax';
use TRunner::Bridge::Smolder;
use File::ShareDir qw/dist_dir/;
use File::Basename qw/fileparse/;
use Config::General qw/ParseConfig/;
use YAML::XS;

unless($ENV{TRUNNER_DEVEL}) {
    ## dynamic configuration here
    my $dist_dir = dist_dir('TRunner');
    if ($dist_dir) {
        set views => "$dist_dir/views";
        set public => "$dist_dir/public";
    }
}

my $selenium_conf;

hook before => sub {
    my $dir = $ENV{TRUNNER_CONFDIR} ? $ENV{TRUNNER_CONFDIR} : 'seleinum/';
    opendir my $confdir, $dir or die;
    $selenium_conf = {};
    while ( my $file = readdir($confdir) ) {
        $file = File::Spec->catfile($ENV{TRUNNER_CONFDIR}, $file);
        next unless -f $file;
        next unless $file =~ /\.ya?ml$/i;
        my ($filename) = fileparse( $file, qr/\.[^.]*/ );
        $selenium_conf->{$filename} = YAML::XS::LoadFile($file) or die;
    }
    if ( -f "$ENV{HOME}/.trunner" ) {
        my %config = ParseConfig("$ENV{HOME}/.trunner");
        config->{smolder} = $config{smolder} if defined $config{smolder};
    }
    closedir($confdir);
};

get '/' => sub {
    template 'index', { config => config, suites => [ keys %$selenium_conf ] };
};

get '/test-runner/:suite' => sub {
    my $suite = params->{suite};
    send_error( "Bad Request", 400 ) unless params->{test};
    template 'test-runner', { suite => $suite };
};

get '/test-case/:suite/:name' => sub {
    my $suite    = params->{suite};
    my $name     = params->{name};
    my $test_col = $selenium_conf->{$suite}->{TestCase}->{$name};
    send_error( "Not Found", 404 ) unless $test_col;
    template 'test-case', { tcase => $test_col, suite => $suite };
};

get '/test-suite/:suite' => sub {
    my $suite = params->{suite};
    template 'test-suite',
      { tcase => $selenium_conf->{$suite}->{TestCase}, suite => $suite };
};

post '/post-results' => sub {
    my %params = params;

    my $is_passed    = 0;
    my $smolder_conf = config->{smolder};
    $smolder_conf->{project_id} ||= $selenium_conf->{project_id};

    $is_passed = 1 unless $smolder_conf->{server};
    $is_passed = 1 unless $smolder_conf->{project_id};

    return template 'post-results' if $is_passed;

    my $smolder = TRunner::Bridge::Smolder->new(
        "user_agent" => request->user_agent,
        "params"     => \%params,
        "config"     => $smolder_conf,
    );
    $smolder->upload;
    template 'post-results';
};

true;
