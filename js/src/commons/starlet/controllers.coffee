module = angular.module("commons.starlet.controllers", ['commons.starlet.services'])


module.controller("VoteCtrl", ($scope, $state, Profile, Vote, ObjectProfileLink) ->
    $scope.enableVote = false
    $scope.voteItems = {}
    $scope.savedProfileVotes = {}
    $scope.currentScore = {}


    $scope.loadVotes = (profileID, objectTypeName, objectID) ->
        Vote.one().customGET('types/').then((voteTypeResults) ->
            angular.forEach(voteTypeResults, (voteType) ->
                $scope.voteItems[voteType.code] = {
                    name : voteType.name
                    votersCount : 0
                    score : 0
                }
                if !$scope.currentScore.hasOwnProperty(voteType.code)
                    $scope.currentScore[voteType.code] = 0
                    $scope.savedProfileVotes[voteType.code] = null

                Vote.getList({content_type : objectTypeName, object_id : objectID, vote_type : voteType.code}).then((voteResults) ->
                    angular.forEach(voteResults, (vote) ->
                        ObjectProfileLink.one().get({content_type : 'vote', object_id : vote.id}).then((objectProfileLinkResults) ->
                            if objectProfileLinkResults.objects.length == 1
                                $scope.voteItems[vote.vote_type].votersCount += 1
                                $scope.voteItems[vote.vote_type].score += vote.score
                                if profileID == objectProfileLinkResults.objects[0].profile.id
                                    vote.voterProfileID = profileID
                                    $scope.currentScore[vote.vote_type] = vote.score
                                    $scope.savedProfileVotes[vote.vote_type] = vote
                        )
                    )
                )
            )
        )

    $scope.saveVote = (profileID, objectTypeName, objectID, voteType, score, objectProfileLinkType) ->
        vote =
            vote_type : voteType
            score : score

        Vote.one().customPOST(vote, objectTypeName+"/"+objectID).then((voteResult) ->
            ObjectProfileLink.one().customPOST(
                profile_id: profileID,
                level: objectProfileLinkType,
                detail : '',
                isValidated:true
            , 'vote/'+voteResult.id).then(->
                $scope.loadVotes(profileID, objectTypeName, objectID)
            )
        )

    $scope.updateVote = (voteType) ->
        savedVote = $scope.savedProfileVotes[voteType]
        Vote.one(savedVote.id).patch({score : savedVote.score}).then(() ->
            $scope.loadVotes(savedVote.voterProfileID, savedVote.content_type, savedVote.object_id)
        )
)
