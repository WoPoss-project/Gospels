import module namespace woposs = "http://woposs.unine.ch" at "functions.xquery";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method 'text';

declare variable $languagesDocs as node()+ := collection('../to-be-aligned/?select=*.xml')//cesDoc;
declare variable $languagesNames := for $uri in $languagesDocs/base-uri(.) return 'Verse ' || substring-after(substring-before($uri, '.xml'), '/to-be-aligned/');

(:generate the column headers of the datasheet :)
let $headerValues := ('Gospel', 'ID', 'Verse number according to Christodouloupoulos and Steedman (2015)', 'Marker GRC', 'Marker LA', 'Verse GRC', 'Verse LA',
  $languagesNames, 'SoA', 'Ambiguous modal reading', 'Modal type', 'Notional domain', 'Subtype / degree', 'Inevitability / prospective')
return
    string-join($headerValues, '&#x9;') || '&#10;'
,
(:global variable to hold the source texts:)
let $collection as node()+ := collection('../xml/')//tei:TEI

(:variable to hold the Feature Structures (the analysis) of the markers which are pertinent:)
let $modalFsMarkers := $collection//tei:fs[@type eq 'marker'][tei:f[@name eq 'pertinence']/tei:binary/@value eq 'true']

(:get only markers that are modal and that have an @xml:id attribute (that way we avoid duplicates:)
let $modalMarkers := $collection//tei:seg[@xml:id][@function eq 'marker'][some $x in tokenize(@ana, '\s+')
    satisfies substring($x, 2) = $modalFsMarkers/@xml:id]

(:get the FS ids of the modal markers (that is, the value of the @ana attribute:)
let $anas := for $x in $modalMarkers/tokenize(@ana, '\s+')
return
    substring($x, 2)
    
    (: to create a row for each modal relation, get all modal relations of the selected modal markers and loop over them :)
let $modalRelations := $collection//tei:fs[@type eq 'relation'][tei:f[@name eq 'marker']/@fVal = ($anas)]
for $modalRelation in $modalRelations

(:obtain the marker of the modal relation we are looping over :)
let $markerId := $modalRelation/tei:f[@name eq 'marker']/@fVal
let $marker := $collection//tei:seg[@xml:id][@function eq 'marker'][some $x in tokenize(@ana, '\s+')
    satisfies substring($x, 2) = $markerId]

(:get its counterpart in the other Gospel:)
let $translation := $collection//tei:seg[some $x in tokenize(@synch, '\s+')
    satisfies substring($x, 2) = $marker/@xml:id]

(:regroup the selected modal marker (the one with @xml:id) and its counterpart (“translation”) by language:)
let $markerGrc := if ($marker/ancestor::tei:TEI/@xml:lang eq 'grc') then
    $marker
else
    $translation
let $markerLa := if ($marker/ancestor::tei:TEI/@xml:lang eq 'la') then
    $marker
else
    $translation
    
    (:variable to hold the ID with the analytical information of the markers and then use that ID to obtain its 
Feature Structure (FS) description:)
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
        
(:FS of the scope:)
let $scopeId := $modalRelation/tei:f[@name eq 'scope']/@fVal
let $scopeFs := $collection//tei:fs[@type eq 'scope']/id($scopeId)
(:State of affairs:)
let $soa := if ($scopeFs/tei:f[@name eq 'SoA']/tei:binary/@value eq 'false') then
    'false'
else
    'true'

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

(:get verse number (using greek as a reference) :)
let $verseNumber := string-join(distinct-values($verseGrc/@id), ', ')

(:check whether there are other modal relations with the same marker and scope as the one being looped over; if so, it’s ambiguous :)
let $ambiguity := woposs:get-ambiguity($modalRelation)

(:get the different features of the modal reading: modal meaning, types, subtypes, degree, function :)
let $modalMeaning := $modalRelation/tei:f[@name eq 'modality']/tei:symbol/@value
let $notionalDomain := if ($modalRelation/descendant::tei:symbol/@value = 'dynamic') then
    $modalRelation/tei:f[@name eq 'meaning']/tei:symbol/@value
else
    $modalRelation/tei:f[@name eq 'type']/tei:symbol/@value => replace('_', ' ')
let $modalSubtype := ($modalRelation[not(descendant::tei:symbol/@value = 'situational')]/tei:f[@name = ('degree', 'subtype')]/tei:symbol/@value | $modalRelation[descendant::tei:symbol/@value = 'dynamic']/tei:f[@name = 'type']/tei:symbol/@value) => replace('_', ' ')
let $situationalSubtype := $modalRelation[descendant::tei:symbol/@value = 'situational']/tei:f[@name eq 'subtype']/tei:symbol/@value => replace('_', ' ')

let $verses := $languagesDocs//seg[@id = $verseNumber]

(:select all variables that will be presented in the table as column values :)
let $colValues := ($marker/ancestor::tei:TEI/@source, $marker/@xml:id, $verseNumber, $citationFormGrc, $citationFormLa, $verseGrcContents,
$verseLaContents, (for $verse in $verses return $verse/normalize-space(.)),$soa, $ambiguity,
$modalMeaning, $notionalDomain, 
if ($modalSubtype) then
    $modalSubtype
else
    '', if ($situationalSubtype) then
    $situationalSubtype
else
    '')
(:return a tabular separated row with the column values :)
return
    string-join($colValues, '&#x9;') || '&#10;'
