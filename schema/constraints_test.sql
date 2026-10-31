\set ON_ERROR_STOP off
\set VERBOSITY verbose

\echo 'Running the four original invalid inserts in separate autocommit transactions.'
\i schema/invalid_data.sql
