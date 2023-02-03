import module namespace woposs = "http://woposs.unine.ch" at "functions.xquery";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method 'text';

(:generate the column headers of the datasheet :)
let $headerValues := ('Gospel', 'Marker ID', 'Verse number according to Christodouloupoulos and Steedman (2015)', 'Marker GRC', 'Marker LA', 'Context GRC', 'Context LA',
'Pertinence GRC', 'Pertinence LA', 'Implicit GRC', 'Implicit LA', 'Synoptic')
return
    string-join($headerValues, '&#x9;') || '&#10;'
,


(: global variables to hold the datasets :)
let $collection as node()+ := collection('../xml/')//tei:TEI

(: Get the markers in the texts :)
let $markers as node()+ := $collection//tei:seg[@xml:id][@function eq 'marker']
for $marker in $markers

(: get translation and all segments that compone each translation  :)
let $translation as node()? := $collection//tei:seg[some $x in tokenize(@synch, '\s+')
    satisfies substring($x, 2) = $marker/@xml:id]


(:regrouping of marker and translation by language:)
let $markerGrc := if ($marker/ancestor::tei:TEI/@xml:lang eq 'grc') then
    $marker
else
    $translation
let $markerLa := if ($marker/ancestor::tei:TEI/@xml:lang eq 'la') then
    $marker
else
    $translation
    
    (:variable to hold the ID with the analytical information of the markers and then use that ID to obtain its 
Feature Structure description:)
let $markerFsIdGrc as xs:string* := for $id in tokenize($markerGrc/@ana)
return
    substring($id, 2)
let $markerFsGrc := $collection/id($markerFsIdGrc)
let $markerFsIdLa as xs:string* := for $id in tokenize($markerLa/@ana)
return
    substring($id, 2)
let $markerFsLa := $collection/id($markerFsIdLa)


(:citation form of both languages; add “not aligned” if there is an empty <s> element with the anchor (that is, the verse does not exist), and
“not preselected” if there is no counterpart :)
let $citationFormGrc := if ($markerFsGrc) then
    woposs:citation-form($markerFsGrc)
else
    if ($collection/descendant::tei:s[substring(@synch, 2) = $marker/@xml:id][not(child::*)]) then
        'not aligned'
    else
        'not preselected'
let $citationFormLa := if ($markerFsLa) then
    woposs:citation-form($markerFsLa)
else
    if ($collection/descendant::tei:s[substring(@synch, 2) = $marker/@xml:id][not(child::*)]) then
        'not aligned'
    else
        'not preselected'
        
        
        (:binary value to indicate the pertinence of the marker:)
let $pertinenceGrc := if ($markerFsGrc) then
    $markerFsGrc/tei:f[@name eq 'pertinence']/tei:binary/@value/string()
else
    'false'
let $pertinenceLa := if ($markerFsLa) then
    $markerFsLa/tei:f[@name eq 'pertinence']/tei:binary/@value/string()
else
    'false'
    
    (:binary value to indicate whether the marker was implicit:)
let $implicitValGrc := if ($markerGrc/ancestor::tei:supplied) then
    'true'
else
    'false'
let $implicitValLa := if ($markerLa/ancestor::tei:supplied) then
    'true'
else
    'false'
    
    
    (:for each language, get the <s> element that contains the marker. If the marker was annotated, get its
<s> ancestor; if it’s not annotated, look for the @synch attribute in a <s> element :)
let $verseGrc := if ($markerGrc) then
    $markerGrc/ancestor::tei:s
else
    $collection/descendant::tei:s[some $x in tokenize(@synch, '\s+')
        satisfies substring($x, 2) = $marker/@xml:id]
let $verseLa := if ($markerLa) then
    $markerLa/ancestor::tei:s
else
    $collection/descendant::tei:s[some $x in tokenize(@synch, '\s+')
        satisfies substring($x, 2) = $marker/@xml:id]
    
    (:to present the verse contents, we pass the <s> element as a parameter of the locally declared
function woposs:get-verse contents():)
let $verseGrcContents := woposs:get-verse-contents($verseGrc)
let $verseLaContents := woposs:get-verse-contents($verseLa)


(:get the ID of the synoptic passage:)
let $synopticVal := distinct-values(($verseLa/@type, $verseGrc/@type))

(:get verse number (using greek as a reference) :)
let $verseNumber := string-join(distinct-values($verseGrc/@id), ', ')

(:select all variables that will be presented in the table as column values :)
let $colValues := ($marker/ancestor::tei:TEI/@source, $marker/@xml:id, $verseNumber, $citationFormGrc, $citationFormLa, $verseGrcContents, $verseLaContents,
$pertinenceGrc, $pertinenceLa, $implicitValGrc, $implicitValLa,
if (exists($synopticVal)) then
    $synopticVal
else
    ' ')

(:return a tabular separated row with the column values:)
return
    string-join($colValues, '&#x9;') || '&#10;'