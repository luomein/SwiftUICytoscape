var cy;

document.addEventListener('DOMContentLoaded', function () {
    //console.log('DOMContentLoaded');
                //document.getElementById("test").innerHTML = "DOMContentLoaded";
          webkit.messageHandlers.DOMContentLoaded.postMessage('DOMContentLoaded');
});
function clearCanvas(){
    document.getElementById("cyContainer").innerHTML = "";
    var cyCanvas = document.createElement('div');
    cyCanvas.id = "cy";
    document.getElementById("cyContainer").append(cyCanvas);
}
function configCytoscape(data, style){
    
    
            cy = cytoscape({
                container: document.getElementById("cy"),
                style: style,
                elements: data,
                layout: {
                    name: 'grid'
                }
            });
            addCytoscapeEventListener(cy);
    return 0;
}
function addCytoscapeEventListener(cy){
            cy.on("click", "node", function(event) {
                    //var nodeId = event.target.id();
                    console.log(event);
                console.log(event.target.isEdge());
                console.log(event.target.isNode());
                console.log(event.target.className());
                    // Send the event to Swift
                    window.webkit.messageHandlers.CytoscapeEvent.postMessage({
                        eventType: event.type,
                        targetId: event.target.id(),
                        isNode: event.target.isNode(),
                        isEdge: event.target.isEdge()
                    });
                });
    cy.on("tap", "node", function(event) {
            //var nodeId = event.target.id();
            console.log(event);
        console.log(event.target.isEdge());
        console.log(event.target.isNode());
        console.log(event.target.className());
            // Send the event to Swift
            window.webkit.messageHandlers.CytoscapeEvent.postMessage({
                eventType: event.type,
                targetId: event.target.id(),
                isNode: event.target.isNode(),
                isEdge: event.target.isEdge()
            });
        });
}
