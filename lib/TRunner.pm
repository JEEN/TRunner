package TRunner;
use utf8;
use Dancer ':syntax';
use TRunner::Bridge::Smolder;
use YAML::XS;
our $VERSION = '0.1';

my $selenium_conf = YAML::XS::LoadFile($ENV{TRUNNER_CONF} || path(setting('confdir') || setting('appdir'), 'selenium.yml'));

get '/' => sub {
    template 'index', { config => config };
};

get '/test-runner' => sub {
    send_error("Bad Request", 400) unless params->{test};
    template 'test-runner';
};

get '/test-case/:name' => sub {
    my $name = params->{name};
    my $test_col = $selenium_conf->{TestCase}->{$name};
    send_error("Not Found", 404) unless $test_col;
    template 'test-case', { tcase => $test_col };
};

get '/test-suite' => sub {
  template 'test-suite', { tsuite => $selenium_conf->{TestSuite} };
};

post '/post-results' => sub {
  my %params = params;

  my $is_passed = 0;
  my $smolder_conf = config->{smolder};
     $smolder_conf->{project_id} ||= $selenium_conf->{project_id};
  
  $is_passed = 1 unless $smolder_conf->{server};
  $is_passed = 1 unless $smolder_conf->{project_id};

  return template 'post-results' if $is_passed;

  my $smolder = TRunner::Bridge::Smolder->new(
    "user_agent" => request->user_agent,
    "params"  => \%params,
    "config"  => $smolder_conf,
  );
  $smolder->upload;
  template 'post-results';
};

true;
