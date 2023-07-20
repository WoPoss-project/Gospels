module namespace woposs = "http://woposs.unine.ch";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:function to format the citation form of the marker:)
declare function woposs:citation-form($fs as node()+) as xs:string {
    let $lemma := $fs/tei:f[@name eq 'lemma']/tei:symbol/@value/string()
    let $correctedLemma := if (contains($lemma, '_inf')) then
        replace($lemma, '_inf', ' + inf.')
    else
        replace($lemma, '_', ' ')
    return
        $correctedLemma
};


(:function to format the contents of an <s> element, normalizing white space and introducing 
curly braces to delimit implicit contents:)
declare function woposs:get-verse-contents($s as node()*) as xs:string {
    let $nodes := for $x in $s/node()
    return
        if ($x/self::tei:supplied) then
            '{' || $x || '}'
        else
            if ($x/tei:supplied) then
                for $y in $x/node()
                return
                    if ($y/self::tei:supplied) then
                        '{' || $y || '}'
                    else
                        $y
            else
                $x
    return
        string-join($nodes, ' ') => normalize-space()
};

(:check whether there are other modal relations with the same marker and scope as the one passed as an argument :)
declare function woposs:get-ambiguity($modalRelation as node()) as xs:string {
    let $markerId := $modalRelation/tei:f[@name eq 'marker']/@fVal
    let $scopeId := $modalRelation/tei:f[@name eq 'scope']/@fVal
    return
        if (($modalRelation/following-sibling::tei:fs/tei:f[@name eq 'marker']/@fVal = $markerId or $modalRelation/preceding-sibling::tei:fs/tei:f[@name eq 'marker']/@fVal = $markerId)
        and ($modalRelation/following-sibling::tei:fs/tei:f[@name eq 'scope']/@fVal = $scopeId or $modalRelation/preceding-sibling::tei:fs/tei:f[@name eq 'scope']/@fVal = $scopeId)) then
            'true'
        else
            'false'
};
