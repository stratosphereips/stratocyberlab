CREATE ROLE relay_guest LOGIN;
CREATE ROLE vault_operator LOGIN PASSWORD 'orbit-7';
CREATE DATABASE pastevault;
\connect pastevault

CREATE TABLE public.access_notes (
    account_name text NOT NULL,
    account_password text NOT NULL,
    note text NOT NULL
);
INSERT INTO public.access_notes VALUES
    ('vault_operator', 'orbit-7', 'Night shift reminder: the dispatch ledger is restricted to the operator account.');
GRANT CONNECT ON DATABASE pastevault TO relay_guest, vault_operator;
GRANT SELECT ON TABLE public.access_notes TO relay_guest;

CREATE TABLE public.protected_dispatch (
    flag text NOT NULL
);
INSERT INTO public.protected_dispatch VALUES ('BSY{Np9Pu1Jy4aOlxOhyCCvjmkOrZGYkXROT}');
REVOKE ALL ON TABLE public.protected_dispatch FROM PUBLIC;
GRANT SELECT ON TABLE public.protected_dispatch TO vault_operator;
