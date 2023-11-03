var cy;

document.addEventListener('DOMContentLoaded', function () {
    //console.log('DOMContentLoaded');
                //document.getElementById("test").innerHTML = "DOMContentLoaded";
    document.getElementById("userAgent").innerHTML = navigator.userAgent
          webkit.messageHandlers.DOMContentLoaded.postMessage('DOMContentLoaded');
});
function clearCanvas(){
    document.getElementById("cyContainer").innerHTML = "";
    var cyCanvas = document.createElement('div');
    cyCanvas.id = "cy";
    document.getElementById("cyContainer").append(cyCanvas);
}
function configCytoscape(data, style, isMobile){
    
    
            cy = cytoscape({
                container: document.getElementById("cy"),
                style: style,
                elements: data,
                layout: {
                    name: 'grid'
                }
            });
            addCytoscapeEventListener(cy, isMobile);
    return 0;
}
//function isMobile() {
//    return navigator.userAgent.match(/(iPod|iPhone|iPad)/)
//}
function addCytoscapeEventListener(cy, isMobile){
    var clickOrTap = isMobile ? "tap" : "click" ;
    
    cy.on(clickOrTap, "node", function(event) {
            //var nodeId = event.target.id();
            //console.log(event);
            //console.log(event.target.isEdge());
            //console.log(event.target.isNode());
            //console.log(event.target.className());
            // Send the event to Swift
            window.webkit.messageHandlers.CytoscapeEvent.postMessage({
            eventType: event.type,
            targetId: event.target.id(),
            isNode: event.target.isNode(),
            isEdge: event.target.isEdge()
            });
        });
    cy.on(clickOrTap, "edge", function(event) {
            //var nodeId = event.target.id();
            //console.log(event);
            //console.log(event.target.isEdge());
            //console.log(event.target.isNode());
            //console.log(event.target.className());
            // Send the event to Swift
            window.webkit.messageHandlers.CytoscapeEvent.postMessage({
            eventType: event.type,
            targetId: event.target.id(),
            isNode: event.target.isNode(),
            isEdge: event.target.isEdge()
            });
        });
    
}
