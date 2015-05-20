/**
 * Created by Saul on 5/16/2015.
 */

function loadData(d){
    clearSelection();
    description.text(d.Description);
    textUrl.text(d.textUrl);
    var divs = directions.selectAll('div')
        .data(d.Offices)
        .enter()
        .append('div')
        .attr('class','directionContent')
        /* .append('text')
         .attr('class','directionText')*/
        .html(function(d){
            return d.text;
        })

    var jsonCircles = [];
    for(var i=0;i< d.Offices.length;i++){
        var path = svg.select("#"+d.Offices[i].cityId);
        path.attr("class","selected");
        jsonCircles.push(d.Offices[i].circle);
    }
    var circles = svg.selectAll("circle")
        .data(jsonCircles)
        .enter()
        .append("circle");

    var circleAttributes = circles
        .attr("cx", function (d) { return d.x_axis; })
        .attr("cy", function (d) { return d.y_axis; })
        .attr("r", function (d) { return d.radius; })
        .attr('data-cx', function (d) { return d.x_axis*-3; })
        .style("fill", function(d) { return d.color; })
        .each(pulse);

}

function clearSelection(){
    svg.selectAll('.selected').attr('class','land');
    svg.selectAll('circle').remove();
    directions.selectAll('div').remove();

}
function pulse() {
    var circle = svg.selectAll("circle");
    (function repeat() {
        circle = circle.transition()
            .duration(100)
            .attr("r", 3)
            .style("opacity",1)
            .transition()
            .duration(1000)
            .attr("r", 10)
            .style("opacity",0.2)
            .ease('sine')
            .each("end", repeat);
    })();
}
