#!/bin/bash
###############################################################################
#
# Bash Remediation Script for Standard System Security Profile for SUSE Linux Enterprise 11
#
# Profile Description:
# This profile contains rules to ensure standard security baseline
# of a SUSE Linux Enterprise 11 system. Regardless of your system's workload
# all of these checks should pass.
#
# Profile ID:  standard
# Benchmark ID:  SUSE-11
# Benchmark Version:  0.1.52
# XCCDF Version:  1.1
#
# This file was generated by OpenSCAP 1.3.3 using:
# $ oscap xccdf generate fix --profile standard --fix-type bash xccdf-file.xml
#
# This Bash Remediation Script is generated from an OpenSCAP profile without preliminary evaluation.
# It attempts to fix every selected rule, even if the system is already compliant.
#
# How to apply this Bash Remediation Script:
# $ sudo ./remediation-script.sh
#
###############################################################################

###############################################################################
# BEGIN fix (1 / 3) for 'file_groupowner_etc_passwd'
###############################################################################
(>&2 echo "Remediating rule 1/3: 'file_groupowner_etc_passwd'")


chgrp 0 /etc/passwd

# END fix for 'file_groupowner_etc_passwd'

###############################################################################
# BEGIN fix (2 / 3) for 'file_owner_etc_passwd'
###############################################################################
(>&2 echo "Remediating rule 2/3: 'file_owner_etc_passwd'")


chown 0 /etc/passwd

# END fix for 'file_owner_etc_passwd'

###############################################################################
# BEGIN fix (3 / 3) for 'file_permissions_etc_passwd'
###############################################################################
(>&2 echo "Remediating rule 3/3: 'file_permissions_etc_passwd'")


chmod 0644 /etc/passwd

# END fix for 'file_permissions_etc_passwd'

