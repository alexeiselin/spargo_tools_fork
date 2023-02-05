## 0.0.1

* First release

## 0.0.2

* Update LICENSE

## 0.0.3

* Change intefaces to base classes

## 0.0.4

* Make some interfaces

## 0.0.5

* Created new model CancelCompeleter
* Added test for CancelCompeleter
* Added new exception RequestCanceledException
* Added the ability to cancel a request using CancelCompleter in AppHttp.apiHttpRequest
* Changed file structure for http_client

## 0.0.6

* Methods for requests are moved from BaseCubit into two mixins, to use the old methods baseRequest and baseRequestOld, use the BaseCubitRequestMixinOld mixin
* Added parameter authorizationToken in AppHttp.apiHttpRequest
* Added test for BaseCubit
