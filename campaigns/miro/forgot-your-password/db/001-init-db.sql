create table actual_user(username text primary key, password_hash text not null);

-- "you will never guess this super complicated password so do not even try"
insert into actual_user values('1c7b8d1d-87ac-4260-87ca-a21477d275da', '$2a$14$6vcNd8jfjfgppa1VooxzDehcaxqITQVknT7cPohOto6dRm0I24T5u');

create function auth_attempt(username text, password_hash text)
    returns boolean
    security definer
    as $$
    begin
        return (select count(*)
                from actual_user u
                where u.username = auth_attempt.username and u.password_hash = auth_attempt.password_hash
                ) = 1;
    end;
$$ language plpgsql;

create user authus_app password 'authus_app';

revoke all privileges on all tables in schema public from authus_app;
grant execute on function auth_attempt(username text, password_hash text) to authus_app;


