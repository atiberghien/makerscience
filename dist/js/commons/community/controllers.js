(function() {
  var module;

  module = angular.module('commons.community.controllers', []);

  module.controller("CommunityCtrl", function($scope, $filter, $interval, Profile, ObjectProfileLink) {
    "Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )\nLa sémantique des niveaux d'implication est à préciser en fonction de la resource.\nA titre d'exemple, pour les projets et fiche ressource MakerScience :\n- 0 -> Membre de l'équipe projet\n- 1 -> personne ressource\n- 2 -> fan/follower\n\nNB. les objets \"profile\" manipulé ici sont les profils génériques du dataserver (et non les MakerScienceProfile)\n    dispo à api/v0/accounts/profile (cf service \"Profile\")";
    $scope.profiles = Profile.getList().$object;
    $scope.teamCandidate = null;
    $scope.resourceCandidate = null;
    $scope.communityObjectTypeName = $scope.objectTypeName;
    $scope.communityObjectID = $scope.objectId;
    return ObjectProfileLink.one().customGETLIST($scope.communityObjectTypeName + '/' + $scope.communityObjectID).then(function(objectProfileLinkResults) {
      $scope.community = objectProfileLinkResults;
      $scope.addMember = function(profile, level, detail, isValidated) {
        if ($scope.isAlreadyMember(profile, level)) {
          return true;
        }
        return ObjectProfileLink.one().customPOST({
          profile_id: profile.id,
          level: level,
          detail: detail,
          isValidated: isValidated
        }, $scope.communityObjectTypeName + '/' + $scope.communityObjectID).then(function(objectProfileLinkResult) {
          return $scope.community.push(objectProfileLinkResult);
        });
      };
      $scope.isAlreadyMember = function(profile, level) {
        return profile && $filter('filter')($scope.community, {
          $: profile.resource_uri,
          level: level,
          isValidated: true
        }).length === 1;
      };
      $scope.removeMember = function(member) {
        return ObjectProfileLink.one(member.id).remove().then(function() {
          var memberIndex;
          memberIndex = $scope.community.indexOf(member);
          $scope.community.splice(memberIndex, 1);
          if ((member.level === 0 || member.level === 10) && member.profile.id === $scope.currentMakerScienceProfile.parent.id) {
            return $scope.editable = false;
          }
        });
      };
      $scope.deleteMember = function(profile, level) {
        return ObjectProfileLink.one().customGET($scope.communityObjectTypeName + '/' + $scope.communityObjectID, {
          profile_id: profile.id,
          level: level
        }).then(function(objectProfileLinkResults) {
          return angular.forEach(objectProfileLinkResults.objects, function(link) {
            return $scope.removeMember(link);
          });
        });
      };
      $scope.validateMember = function(member, isValidated) {
        var data;
        data = {
          isValidated: isValidated
        };
        if (member.level === 5) {
          member.level = data["level"] = 0;
          member.detail = data["detail"] = "";
        } else if (member.level === 6) {
          member.level = data["level"] = 1;
          member.detail = data["detail"] = "";
        } else if (member.level === 15) {
          member.level = data["level"] = 10;
          member.detail = data["detail"] = "";
        } else if (member.level === 16) {
          member.level = data["level"] = 11;
          member.detail = data["detail"] = "";
        }
        return ObjectProfileLink.one(member.id).patch(data).then(function() {
          var memberIndex;
          memberIndex = $scope.community.indexOf(member);
          member = $scope.community[memberIndex];
          member.isValidated = isValidated;
          if ((member.level === 0 || member.level === 10) && member.profile.id === $scope.currentMakerScienceProfile.parent.id) {
            return $scope.editable = isValidated;
          }
        });
      };
      $scope.updateMemberDetail = function(detail, member) {
        ObjectProfileLink.one(member.id).patch({
          detail: detail
        }).then(function() {
          var memberIndex;
          memberIndex = $scope.community.indexOf(member);
          member = $scope.community[memberIndex];
          member.detail = detail;
          return true;
        });
        return false;
      };
      return $scope.community;
    });
  });

}).call(this);
