var cy;

document.addEventListener('DOMContentLoaded', function () {
          webkit.messageHandlers.DOMContentLoaded.postMessage('DOMContentLoaded')
});

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
}
function addCytoscapeEventListener(cy){
            cy.on("click", "node", function(event) {
                    var nodeId = event.target.id();
                    console.log(event);
                    // Send the event to Swift
                    //window.webkit.messageHandlers.cytoscapeEvent.postMessage({
                    //    type: "nodeClick",
                    //    nodeId: nodeId
                    //});
                });
}
