

var app = angular.module('myApp', []); 
app.controller('myCtrl', function($scope, $http) {
    $scope.docList = [{webUrl:'Your documents will appear in here!', downloadUrl:'#'}];
    //get a guest session
    $http.get('/api/login').then(function(response){
        if('msg' in response.data){
    	    $http.get('/api/docs').then(function(response){
		if(Object.keys(response.data).length != 0){
                    $scope.docList = [];
		    for(var key in response.data){
                        $scope.docList.push({webUrl:key, downloadUrl:response.data[key]});	
		    }
		}
            });
	}
    });

    $scope.docAdd = function() {
	var url = $scope.docUrlInput;
	$http({
            url: 'api/docs',
            method: 'POST',
            data: 'url='+url,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        }).then(function(response) {
	    //Erase message on first use
	    if ($scope.docList[0]['downloadUrl'] == '#')
                $scope.docList = [];

	    resp = response.data
            $scope.docList.push({webUrl:url, downloadUrl:resp["url"]});
            $scope.docUrlInput = "";
        });
    };

    $scope.remove = function() {
        var oldList = $scope.docList;
        $scope.docList = [];
        angular.forEach(oldList, function(x) {
            if (!x.done) $scope.docList.push(x);
        });
    };
});
