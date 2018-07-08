% Credits: this code was originally part of the `dialyxir` project
% Copyright by Andrew Summers
% https://github.com/jeremyjh/dialyxir

Definitions.

WHITESPACE=[\s\t\r\n]+
INT = -?[0-9]+
NUMBERED = _@[0-9]+::
REST = \.\.\.
RANGE = \.\.
ATOM = \'[^']+\'

Rules.

{WHITESPACE} : skip_token.
{NUMBERED} : skip_token.

{REST} : {token, {'...', TokenLine}}.
fun\( : {token, {'fun(',  TokenLine}}.
\* : {token, {'*',  TokenLine}}.
\[ : {token, {'[',  TokenLine}}.
\] : {token, {']',  TokenLine}}.
\( : {token, {'(',  TokenLine}}.
\) : {token, {')',  TokenLine}}.
\{ : {token, {'{',  TokenLine}}.
\} : {token, {'}',  TokenLine}}.
\# : {token, {'#',  TokenLine}}.
\| : {token, {'|',  TokenLine}}.
_ : {token, {'_',  TokenLine}}.
\:\: : {token, {'::',  TokenLine}}.
\: : {token, {':',  TokenLine}}.
\:\= : {token, {':=',  TokenLine}}.
\=\> : {token, {'=>',  TokenLine}}.
\-\> : {token, {'->',  TokenLine}}.
\| : {token, {'|',  TokenLine}}.
\<\< : {token, {'<<', TokenLine}}.
\< : {token, {'<', TokenLine}}.
\>\> : {token, {'>>', TokenLine}}.
\> : {token, {'>', TokenLine}}.
\' : {token, {'\'',  TokenLine}}.
, : {token, {',',  TokenLine}}.
\= : {token, {'=',  TokenLine}}.
{RANGE} : {token, {'..', TokenLine}}.
{INT} : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{ATOM} : {token, {atom_full, TokenLine, TokenChars}}.
. : {token, {atom_part, TokenLine, TokenChars}}.

Erlang code.
