window.addEventListener('message', receiver, false);

function receiver(event) {
  var responseData = JSON.parse(event.data);
  var eventCode = responseData.event;

  if (eventCode == "init"){
    parent.postMessage(buildPostMessage("connected"), "*");
  }
  
  if (eventCode == "loggedIn") {
    _setLegacyCookie(responseData.token, responseData.isSession, location.hostname);
  }

}

function buildPostMessage(status) {
  var responseData = {
    "event": status
  };
  
  return JSON.stringify(responseData);
}

  _setLegacyCookie = function(token, rememberMe, domain) {
    var clientMessage = _buildLegacyPostData(token, rememberMe, domain);
    $.ajax({
       url : "/login/cookies/drop",
       type : 'POST',
       data : clientMessage,
       dataType : "text",
       success : function(data) {
	     parent.postMessage(buildPostMessage("success"), "*");
      },
      error : function(XMLHttpRequest, textStatus, errorThrown) {
		 buildPostMessage("failure");
      }
    });
  };

  _buildLegacyPostData = function(token, rememberMe, domain) {
    var responseData = {
      "token" : token,
      "domain" : domain,
      "session" : rememberMe,
      "uri": "/mwaccount/",
      "policy": "L1"
    };

    return responseData;
  };
  