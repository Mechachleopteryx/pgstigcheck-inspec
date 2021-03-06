pg_ver = input('pg_version')

pg_dba = input('pg_dba')

pg_dba_password = input('pg_dba_password')

pg_db = input('pg_db')

pg_host = input('pg_host')

control "V-72957" do
  title "PostgreSQL must be able to generate audit records when security
  objects are accessed."
  desc  "Changes to the security configuration must be tracked.

  This requirement applies to situations where security data is retrieved or
  modified via data manipulation operations, as opposed to via specialized
  security functionality.

  In an SQL environment, types of access include, but are not necessarily
  limited to:

    CREATE
    SELECT
    INSERT
    UPDATE
    DELETE
    PREPARE
    EXECUTE
    ALTER
    DROP"

  impact 0.5
  tag "severity": "medium"
  tag "gtitle": "SRG-APP-000492-DB-000332"
  tag "gid": "V-72957"
  tag "rid": "SV-87609r2_rule"
  tag "stig_id": "PGS9-00-006000"
  tag "fix_id": "F-79403r2_fix"
  tag "cci": ["CCI-000172"]
  tag "nist": ["AU-12 c", "Rev_4"]
  tag "false_negatives": nil
  tag "false_positives": nil
  tag "documentable": false
  tag "mitigations": nil
  tag "severity_override_guidance": false
  tag "potential_impacts": nil
  tag "third_party_tools": nil
  tag "mitigation_controls": nil
  tag "responsibility": nil
  tag "ia_controls": nil
  desc "check", "First, as the database administrator, verify pgaudit is enabled
  by running the following SQL:

  $ sudo su - postgres
  $ psql -c \"SHOW shared_preload_libraries\"

  If the output does not contain pgaudit, this is a finding.

  Next, verify that role, read, write, and ddl auditing are enabled:

  $ psql -c \"SHOW pgaudit.log\"

  If the output does not contain role, read, write, and ddl, this is a finding."
  
  desc "fix", "Note: The following instructions use the PGDATA and PGVER
  environment variables. See supplementary content APPENDIX-F for instructions on
  configuring PGDATA and APPENDIX-H for  PGVER.

  Using pgaudit PostgreSQL can be configured to audit these requests. See
  supplementary content APPENDIX-B for documentation on installing pgaudit. 

  With pgaudit installed the following configurations can be made: 

  $ sudo su - postgres 
  $ vi ${PGDATA?}/postgresql.conf 

  Add the following parameters (or edit existing parameters): 

  pgaudit.log='ddl, role, read, write' 

  Now, as the system administrator, reload the server with the new configuration: 

  # SYSTEMD SERVER ONLY 
  $ sudo systemctl reload postgresql-${PGVER?}

  # INITD SERVER ONLY 
  $ sudo service postgresql-${PGVER?} reload"


  sql = postgres_session(pg_dba, pg_dba_password, pg_host)

  describe sql.query('SHOW shared_preload_libraries;', [pg_db]) do
    its('output') { should include 'pgaudit' }
  end

  pgaudit_types = %w(ddl read role write)

  pgaudit_types.each do |type|
    describe sql.query('SHOW pgaudit.log;', [pg_db]) do
      its('output') { should include type }
    end
  end
end
