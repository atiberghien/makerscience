module = angular.module('commons.account.directives', ['restangular'])

module.directive('avatarSrc', ($compile) ->
        link = (scope, element, attrs) ->
                if scope.user.mugshot and scope.user.mugshot != ""
                        element.attr('src', scope.user.mugshot)
                else
                        tmpl = "http://sigil.cupcake.io/#{scope.user.username}.png"
                        if scope.size
                                tmpl += "?w=#{scope.size}"

                        element.attr('src', tmpl)

                element.attr('width', scope.size)
                element.attr('height', scope.size)


        return {
                scope:
                        user: "=avatarSrc"
                        size: "=avatarSize"
                restrict: 'A',
                link: link

                }
        )