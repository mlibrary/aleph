riyosha
=======

Riyosha is a central user registry application.

It maintains a user database which can be used to authenticate users for
itself as well as other applications.

Riyosha is intended for use as a CAS server 
([rubycas-server](http://rubycas.github.com/) is one example),
to do the actual authentication for other systems.

Riyosha has 2 user types:
* Users managed by Riyosha
* AdminUsers who can do administrative tasks on users.

Both uer types are authenticated through a Devise setup.
AdminUsers are authenticated through a cas server.
The CAS server may be based on Riyosha it self, but this is not a requirement.
Ordinary users are authenticated from the database in Riyosha or from a configured 
external authentication providers.
