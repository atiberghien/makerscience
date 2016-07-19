(function() {
  var module;

  module = angular.module("commons.starlet.controllers", ['commons.starlet.services']);

  module.controller("VoteCtrl", function($scope, $state, Profile, Vote, ObjectProfileLink) {
    $scope.enableVote = false;
    $scope.voteItems = {};
    $scope.savedProfileVotes = {};
    $scope.currentScore = {};
    $scope.loadVotes = function(profileID, objectTypeName, objectID) {
      return Vote.one().customGET('types/').then(function(voteTypeResults) {
        return angular.forEach(voteTypeResults, function(voteType) {
          $scope.voteItems[voteType.code] = {
            name: voteType.name,
            votersCount: 0,
            score: 0
          };
          if (!$scope.currentScore.hasOwnProperty(voteType.code)) {
            $scope.currentScore[voteType.code] = 0;
            $scope.savedProfileVotes[voteType.code] = null;
          }
          return Vote.getList({
            content_type: objectTypeName,
            object_id: objectID,
            vote_type: voteType.code
          }).then(function(voteResults) {
            return angular.forEach(voteResults, function(vote) {
              return ObjectProfileLink.one().get({
                content_type: 'vote',
                object_id: vote.id
              }).then(function(objectProfileLinkResults) {
                if (objectProfileLinkResults.objects.length === 1) {
                  $scope.voteItems[vote.vote_type].votersCount += 1;
                  $scope.voteItems[vote.vote_type].score += vote.score;
                  if (profileID === objectProfileLinkResults.objects[0].profile.id) {
                    vote.voterProfileID = profileID;
                    $scope.currentScore[vote.vote_type] = vote.score;
                    return $scope.savedProfileVotes[vote.vote_type] = vote;
                  }
                }
              });
            });
          });
        });
      });
    };
    $scope.saveVote = function(profileID, objectTypeName, objectID, voteType, score, objectProfileLinkType) {
      var vote;
      vote = {
        vote_type: voteType,
        score: score
      };
      return Vote.one().customPOST(vote, objectTypeName + "/" + objectID).then(function(voteResult) {
        return ObjectProfileLink.one().customPOST({
          profile_id: profileID,
          level: objectProfileLinkType,
          detail: '',
          isValidated: true
        }, 'vote/' + voteResult.id).then(function() {
          return $scope.loadVotes(profileID, objectTypeName, objectID);
        });
      });
    };
    return $scope.updateVote = function(voteType) {
      var savedVote;
      savedVote = $scope.savedProfileVotes[voteType];
      return Vote.one(savedVote.id).patch({
        score: savedVote.score
      }).then(function() {
        return $scope.loadVotes(savedVote.voterProfileID, savedVote.content_type, savedVote.object_id);
      });
    };
  });

}).call(this);
