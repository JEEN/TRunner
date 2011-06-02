use strict;
use warnings;
use TRunner::Bridge::Smolder;
use Data::Section::Simple qw/get_data_section/;

my $r = TRunner::Bridge::Smolder->new(
  user_agent => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_7) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.772.0 Safari/535.1",
  params => {
    numTestTotal  => 2,
    totalTime     => 54,
    'testTable.1' => get_data_section('testTable1'),
    'testTable.2' => get_data_section('testTable2'),
  },
  config => {
    server => 'your server',
    username => 'username',
    password => 'password',
    project  => 'TRunner',
    project_id => 2,
  },
);

my $r = $r->upload;
use Data::Dumper;
print Dumper $r;
__DATA__

@@ testTable1
<div> <table border="1" cellpadding="1" cellspacing="1"> <thead> <tr
class="title status_failed"><td rowspan="1" colspan="3">login-test</td></tr>
</thead><tbody> <tr class=" status_done" style="cursor: pointer;">
<td>open</td> <td>/login</td> <td></td> </tr> <tr class=" status_failed"
style="cursor: pointer;"> <td>type</td> <td>username</td>
<td>Element&nbsp;username&nbsp;not&nbsp;found</td> </tr> <tr class=""
style="cursor: pointer;"> <td>type</td> <td>password</td> <td>1234</td> </tr>
<tr class="" style="cursor: pointer;"> <td>clickAndWait</td>
<td>css=input[type=submit]</td> <td></td> </tr> <tr class="" style="cursor:
pointer;"> <td>verifyTextPresent</td> <td>logout</td> <td></td> </tr>
</tbody></table> </div>

@@ testTable2
<div> <table border="1" cellpadding="1" cellspacing="1"> <thead> <tr
class="title status_passed"><td rowspan="1" colspan="3">logout-test</td></tr>
</thead><tbody> <tr class=" status_passed" style="cursor: pointer;">
<td>verifyTextPresent</td> <td>logout</td> <td></td> </tr> <tr class="
status_done" style="cursor: pointer;"> <td>clickAndWait</td>
<td>link=logout</td> <td></td> </tr> <tr class=" status_passed" style="cursor:
pointer;"> <td>assertTitle</td> <td>Login</td> <td></td> </tr> </tbody></table>
</div>


