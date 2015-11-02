# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# $origin: https://github.com/OTRS/otrs/blob/a11f0d7a1ed0174e796a11c9998cdb112d0624be/scripts/test/Console/Command/Admin/Service/Add.t
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Admin::Service::Add');

my ( $Result, $ExitCode );

my $HelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $RandomName   = $HelperObject->GetRandomID();
my $RandomName2  = $HelperObject->GetRandomID();

# try to execute command without any options
$ExitCode = $CommandObject->Execute();
$Self->Is(
    $ExitCode,
    1,
    "No options",
);

# provide minimum options
# ---
# ITSM
# ---
#$ExitCode = $CommandObject->Execute( '--name', $RandomName );
$ExitCode = $CommandObject->Execute( '--name', $RandomName, '--criticality', '3 normal', '--type', 'Demonstration' );
# ---
$Self->Is(
    $ExitCode,
    0,
    "Minimum options",
);

# same again (should fail because already exists)
# ---
# ITSM
# ---
#$ExitCode = $CommandObject->Execute( '--name', $RandomName );
$ExitCode = $CommandObject->Execute( '--name', $RandomName, '--criticality', '3 normal', '--type', 'Demonstration' );
# ---
$Self->Is(
    $ExitCode,
    1,
    "Minimum options (already exists)",
);

# invalid parent
# ---
# ITSM
# ---
#$ExitCode = $CommandObject->Execute( '--name', $RandomName2, '--parent-name', $RandomName2 );
$ExitCode = $CommandObject->Execute( '--name', $RandomName2, '--parent-name', $RandomName2, '--criticality', '3 normal', '--type', 'Demonstration' );
# ---
$Self->Is(
    $ExitCode,
    1,
    "Parent does not exist",
);

# valid parent
# ---
# ITSM
# ---
#$ExitCode = $CommandObject->Execute( '--name', $RandomName2, '--parent-name', $RandomName );
$ExitCode = $CommandObject->Execute( '--name', $RandomName2, '--parent-name', $RandomName, '--criticality', '3 normal', '--type', 'Demonstration' );
# ---
$Self->Is(
    $ExitCode,
    0,
    "Existing parent",
);

# delete services
my $Success = $Kernel::OM->Get('Kernel::System::DB')->Do(
    SQL => "DELETE FROM service WHERE name = '$RandomName' OR name = '${RandomName}::${RandomName2}'",
);
$Self->True(
    $Success,
    "ServiceDelete - $RandomName/$RandomName2",
);

# Make sure the cache is correct.
$Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
    Type => 'Service',
);

1;