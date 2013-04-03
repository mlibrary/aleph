riyosha
=======

Riyosha is a central user registery application.

It maintains a user database which can be used to authenticate users for
Riyosha as well as other applications.
Riyosha is intended for use with a CAS server 
([rubycas-server](http://rubycas.github.com/) is one example),
to do the actual authentication for other systems.

Riyosha has 2 user types:
  Users managed by Riyosha
  AdminUsers who can do administrative tasks on users.

Both are authenticated through a Devise setup.
AdminUsers are authenticated through a cas server.
The CAS server may be based on Riyosha it self, but this is not a requirement.
Users are authenticated from the database in Riyosha.

Users can register by going to http://hostname/register.
Before users are active, they must confirm their e-mail address by clicking
on a link sent to the given e-mail.
