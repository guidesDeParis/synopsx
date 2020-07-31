xquery version '3.0' ;
module namespace synopsx.mappings.tei2html = 'synopsx.mappings.tei2html' ;

(:~
 : This module is a TEI to html function library for SynopsX
 :
 : @version 2.0 (Constantia edition)
 : @since 2015-02-17 
 : @author synopsx team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along 
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :)

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace 'synopsx.mappings.tei2html' ;

declare boundary-space strip ;

(:~
 : this function 
 :)
declare 
  %output:indent('no') 
function entry($node as node()*, $options as map(*)) as item()* {
  for $i in $node return dispatch($i, $options)
};

(:~
 : this function dispatches the treatment of the XML document
 :)
declare 
  %output:indent('no') 
function dispatch($node as node()*, $options as map(*)) as item()* {
  typeswitch($node)
    case text() return $node[fn:normalize-space(.)!='']
    case element(tei:persName) return persName($node, $options)
    case element(tei:placeName) return placeName($node, $options)
    case element(tei:objectName) return objectName($node, $options)
    case element(tei:orgName) return orgName($node, $options)
    case element(tei:geogName) return geogName($node, $options)
    case element(tei:fw) return fw($node, $options)
    case element(tei:lb) return lb($node, $options)
    case element(tei:pb) return pb($node, $options)
    case element(tei:hi) return hi($node, $options)
    case element(tei:date) return getDate($node, $options)
    case element(tei:p) return p($node, $options)
    case element(tei:item) return synopsx.mappings.tei2html:item($node, $options)
    case element(tei:label) return label($node, $options)
    case element(tei:emph) return emph($node, $options)
    case element(tei:list) return list($node, $options)
    case element(tei:head) return head($node, $options)
    case element(tei:div) return div($node, $options)
    case element(tei:q) return q($node, $options)
    case element(tei:quote) return quote($node, $options)
    case element(tei:lg) return lg($node, $options)
    case element(tei:l) return l($node, $options)
    case element(tei:ref) return ref($node, $options)
    case element(tei:note) return note($node, $options)
    case element(tei:idno) return idno($node, $options)
    case element(tei:monogr) return getMonogr($node, $options)
    case element(tei:analytic) return getAnalytic($node, $options)
    (: case element(tei:author) return getResponsability($node, $options) :)
    case element(tei:edition) return getEdition($node, $options)
    (: case element(tei:editor) return getResponsability($node, $options) :)
    case element(tei:bibl) return biblItem($node, $options)
    case element(tei:biblStruct) return getBiblStruct($node, $options)
    case element(tei:listBibl) return listBibl($node, $options)
    case element(tei:figure) return figure($node, $options)
    case element(tei:formula) return formula($node, $options)
    case element(tei:graphic) return graphic($node, $options)
    case element(tei:body) return passthru($node, $options)
    case element(tei:back) return passthru($node, $options)
    case element(tei:front) return passthru($node, $options)
    case element(tei:text) return passthru($node, $options)
    case element(tei:teiHeader) return ''
    case element(tei:TEI) return passthru($node, $options)
    case element(tei:said) return said($node, $options)
    case element(tei:mark) return mark($node, $options)
    case element(tei:title) return title($node, $options)
    case element(tei:note) return note($node, $options)
    case element(tei:titlePage) return getTitlePage($node, $options)
    case element(tei:docTitle) return getDocTitle($node, $options)
    case element(tei:titlePart) return getTitlePart($node, $options)
    case element(tei:byline) return getByline($node, $options)
    case element(tei:docImprint) return getDocImprint($node, $options)
    case element(tei:imprimatur) return getImprimatur($node, $options)
    case element(tei:publisher) return getPublisher($node, $options)
    case element(tei:pubPlace) return getPubPlace($node, $options)
    case element(tei:docDate) return getDocDate($node, $options)
    default return passthru($node, $options)
};

(:~
 : This function pass through child nodes (xsl:apply-templates)
 :)
declare 
  %output:indent('no') 
function passthru($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return dispatch($node, $options)
};


(:~
 : ~:~:~:~:~:~:~:~:~
 : tei textstructure
 : ~:~:~:~:~:~:~:~:~
 :)

declare function div($node as element(tei:div)+, $options as map(*)) {
  <div>
    { if ($node/@xml:id) then attribute id { $node/@xml:id } else (),
    passthru($node, $options)}
  </div>
};

declare function head($node as element(tei:head)+, $options as map(*)) as element() {   
  if ($node/parent::tei:div) then
    let $type := $node/parent::tei:div/@type
    let $level := if ($node/ancestor::div) then fn:count($node/ancestor::div) + 1 else 1
    return element { 'h' || $level } { passthru($node, $options) }
  else if ($node/parent::tei:figure) then
    if ($node/parent::tei:figure/parent::tei:p) then
      <strong>{ passthru($node, $options) }</strong>
    else <p><strong>{ passthru($node, $options) }</strong></p>
  else if ($node/parent::tei:list) then
    <strong>{ passthru($node, $options) }</strong>
  else if ($node/parent::tei:table) then
    <th>{ passthru($node, $options) }</th>
  else  <title>{passthru($node, $options)}</title>
};

declare function p($node as element(tei:p)+, $options as map(*)) {
  <p>{ passthru($node, $options) }</p>
};

declare function list($node as element(tei:list)+, $options as map(*)) {
  switch ($node) 
  case $node/@type='ordered' return <ol>{ passthru($node, $options) }</ol>
  case $node[child::tei:label] return <dl>{ passthru($node, $options) }</dl>
  default return <ul>{ passthru($node, $options) }</ul>
};

declare function synopsx.mappings.tei2html:item($node as element(tei:item)+, $options as map(*)) {
  switch ($node)
  case $node[parent::*/tei:label] return <dd>{ passthru($node, $options) }</dd>
  default return <li>{ passthru($node, $options) }</li>
};

declare function label($node as element(tei:label)+, $options as map(*)) {
  <span class="bold">{ passthru($node, $options) }</span>
};

declare function note($node as element(tei:note)+, $options as map(*)) {
  if ($node[parent::tei:biblStruct])
  then <p class='noteBibl'><em>Note : </em> { passthru($node, $options) }</p>
  else
    if ($node/ancestor::tei:back) 
    then 
      <div class="note">
        <a id='{$node/@xml:id}' href='{'#ref' || $node/@xml:id}'>{
          let $ref := $node/ancestor::tei:text//tei:ref[fn:substring-after(@target, '#') = $node/@xml:id]
          return if ($ref) then $ref else ()
        }</a>
        {passthru($node, $options)}</div>
    else (<div class='note'>{passthru($node, $options)}</div>)
};

declare function formula($node as element(tei:formula), $options as map(*)) {
   $node/*
};

declare function title($node as element(tei:title), $options as map(*)) {
   <span class="title">{passthru($node, $options)}</span>
};

declare function quote($node as element(), $options as map(*)) {
  <blockquote>{passthru($node, $options)}</blockquote>
};

declare function lg($node as element(), $options as map(*)) {
  <div class="strophe">{passthru($node, $options)}</div>
};

declare function l($node as element(), $options as map(*)) {
  <p class="vers">{passthru($node, $options)}</p>
};

declare function q($node as element(), $options as map(*)) {
  if ($node/@xml:lang)
  then <quote class="lat">{passthru($node, $options)}</quote>
  else ('« ', passthru($node, $options), ' »')
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei inline
 : ~:~:~:~:~:~:~:~:~
 :)
declare function hi($node as element(tei:hi)+, $options as map(*)) {
  switch ($node)
  case ($node[@rend='italic' or @rend='it']) return <em>{ passthru($node, $options) }</em> 
  case ($node[@rend='bold' or @rend='b']) return <strong>{ passthru($node, $options) }</strong>
  case ($node[@rend='superscript' or @rend='sup']) return <sup>{ passthru($node, $options) }</sup>
  case ($node[@rend='underscript' or @rend='sub']) return <sub>{ passthru($node, $options) }</sub>
  case ($node[@rend='underline' or @rend='u']) return <u>{ passthru($node, $options) }</u>
  case ($node[@rend='strikethrough']) return <del class="hi">{ passthru($node, $options) }</del>
  case ($node[@rend='caps' or @rend='uppercase']) return <span calss="uppercase">{ passthru($node, $options) }</span>
  case ($node[@rend='smallcaps' or @rend='sc']) return <span class="small-caps">{ passthru($node, $options) }</span>
  default return <span class="{$node/@rend}">{ passthru($node, $options) }</span>
};

declare function idno($node as element(tei:idno), $options as map(*)) {
  switch ($node)
  case ($node[@type='todo']) return <em>gallica</em>
  default return <span class="idno">{ passthru($node, $options)}</span>
};

declare function fw($node as element(tei:fw), $options as map(*)) {
  if ($node/@type = 'runningHead') then ()
  else (<span role="pageNum" data-num="{ passthru($node, $options) }"/>, text{' '})
};

declare function lb($node as element(tei:lb), $options as map(*)) {
  let $lb := map:get($options, 'lb')
  return switch($node)
    case ($node[@rend='hyphen'] and $lb) return ('-', <br/>)
    case ($node and $lb) return <br/>
    case ($node[ancestor::tei:titlePage]) return <br/> (: doesnt work :)
    default return ()
};

declare function pb($node as element(tei:pb), $options as map(*)) {
  if ($node/@n)
  then (<br/>, <span class='pb'>{'{' || $node/fn:data(@n) || '}' }</span>)
  else <span role="pageBreak" id="{$node/@xml:id}"/>
};

declare function ref($node as element(tei:ref), $options as map(*)) {
   (<a id='{'ref' || $node/fn:substring-after(@target, '#')}' href='{$node/@target}'>{ passthru($node, $options) }</a>)
 
};

declare function said($node as element(tei:said), $options as map(*)) {
  <quote>{ passthru($node, $options) }</quote>
};


declare function figure($node as element(tei:figure), $options as map(*)) {
  let $figDesc := passthru($node/tei:figDesc, $options)
  let $url := db:open('gdp')//tei:facsimile/tei:surface[@xml:id = fn:substring-after($node/@facs, '#')]/tei:graphic[@n='iiif']/@url
  return
    <figure id="{$node/@xml:id}">
      <img src="{$url}" alt="{$figDesc}"/>
      <figcaption>{ $figDesc }</figcaption>
    </figure>
};

declare function graphic($node as element(tei:graphic), $options as map(*)) {
  if ($node/@url)
  then (<a href='{'/static/img/' || $node/ancestor::tei:TEI//tei:sourceDesc//tei:idno[@type='old'] || '/' || $node/@url}'><img class="displayed" width="400" height="400" src='{'/static/img/' || $node/ancestor::tei:TEI//tei:sourceDesc//tei:idno[@type='old'] || '/' || $node/@url}'/></a>)
  else ()
};

declare function mark($node as element(tei:mark), $options as map(*)) {
  <code>{ passthru($node, $options) }</code>
};

declare function emph($node as element(tei:emph), $options as map(*)) {
  <em class="emph">{ passthru($node, $options) }</em>
};

declare function getDate($node, $options as map(*)) {
  <span class='date'>{ passthru($node, $options)}</span>
};

declare function getPublisher($node, $options) {
  <span class="publisher">{ passthru($node, $options)}</span>
};

declare function getPubPlace($node, $options) {
  <span class="pubPlace">{ passthru($node, $options)}</span>
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei biblio
 : ~:~:~:~:~:~:~:~:~
 :)

declare function listBibl($node, $options as map(*)) {
  <ol id="{$node/@xml:id}">{ passthru($node, $options) }</ol>
};

declare function biblItem($node, $options as map(*)) {
  
  for $node in $node[fn:not(@corresp)]
 (:  order by fn:number(fn:substring($x/@xml:id, 15, 4)), fn:substring($x/@xml:id, 20) :)
  return 
    (:<li id="{$node/@xml:id}">
      <a href="http://localhost:8984/gdp/bibliography/manifestations/{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}">{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}</a>{ passthru($node, $options) }
      {if (fn:exists($node/ancestor::tei:listBibl/tei:biblStruct[fn:substring-after(@corresp, '#') = $node/@xml:id]) )
      then <ul>{
        for $f in $node/ancestor::tei:listBibl/tei:biblStruct[@corresp]
           where fn:substring-after($f/@corresp, '#') = $node/@xml:id
           :)(: order by fn:number(fn:substring($x/@xml:id, 15, 4)), substring($x/@xml:id, 20) :)(:
           return <li  id="{$f/@xml:id}"><a>{$node/fn:data(fn:substring-after($f/@xml:id, 'publi_'))}</a>{ passthru($f, $options) }</li>
        }</ul>
      else ()}
    </li>:)
    <span>{ passthru($node, $options) }</span>
  
 (:  if ($node[tei:idno[@type='M']])
   then <li id="{$node/@xml:id}"><a class="badge" href="http://localhost:8984/gdp/manifestations/{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}">{$node/fn:data(fn:substring-after(@xml:id, 'publi_'))}</a>{ passthru($node, $options) }</li>
   else ()  :)
};

(:~
 : This function treats tei:analytic
 : @todo group author and editor to treat distinctly
 :)
declare function getAnalytic($node, $options as map(*)) {
  getResponsabilities($node, $options), 
  getBibTitle($node, $options)
};

(:~
 : This function treats tei:monogr
 :)
declare function getMonogr($node, $options as map(*)) {
  getResponsabilities($node, $options),
  getBibTitle($node, $options),
  getEdition($node/node(), $options),
  getImprint($node/node(), $options)
};


(:~
 : This function get responsabilities
 : @todo group authors and editors to treat them distinctly
 : @todo "éd." vs "éds."
 :)
declare function getResponsabilities($node, $options as map(*)) {
  let $nbResponsabilities := fn:count($node/tei:author | $node/tei:editor)
  for $responsability at $count in $node/tei:author | $node/tei:editor
  return if ($count = $nbResponsabilities) then (getResponsability($responsability, $options), '. ')
    else (getResponsability($responsability, $options), ' ; ')
};

(:~
 : si le dernier auteur mettre un séparateur à la fin
 :
 :)
declare function getResponsability($node, $options as map(*)) {
  if ($node/tei:forename or $node/tei:surname) 
  then getName($node, $options) 
  else passthru($node, $options)
};

declare function persName($node, $options) {
    getName($node, $options)
};

declare function placeName($node, $options) {
    getName($node, $options)
};

declare function objectName($node, $options) {
   getName($node, $options)
};

declare function orgName($node, $options) {
   getName($node, $options)
};

declare function geogName($node, $options) {
   getName($node, $options)
};

(:~
 : this fonction concatenate surname and forname with a ', '
 :
 : @todo cases with only one element
 : @todo rewrite persName, placeName, objectName
 :)
declare function getName($node, $options as map(*)) {
  switch($node)
  case ($node/tei:forename and $node/tei:surname) return (<span class="smallcaps">{$node/tei:surname/text()}</span>, ', ', $node/tei:forename)
  case ($node[fn:local-name(.) = 'persName']) return indexName($node, map{ 'index' : 'nominum'})
  case ($node[fn:local-name(.) = 'orgName']) return indexName($node, map{ 'index' : 'nominum'})
  case ($node[fn:local-name(.) = 'placeName']) return indexName($node, map{ 'index' : 'locorum'})
  case ($node[fn:local-name(.) = 'geoName']) return indexName($node, map{ 'index' : 'locorum'})
  case ($node[fn:local-name(.) = 'objectName']) return indexName($node, map{ 'index' : 'operum'})
  default return
    if ($node/@ref)
      then <a class="{$node/fn:name()}" href="{$node/@ref}">{passthru($node, $options)}</a>
      else <span class="{$node/fn:name()}">{passthru($node, $options)}</span>
};

declare function indexName($node, $options) {
  if ($node/@ref)
  then <a class="{fn:local-name($node)}" href="{$node/@ref}" data-index="{$options?index}">{passthru($node, $options)}</a>
        else <span class="{fn:local-name($node)}">{passthru($node, $options)}</span>
};
(:~
 : this function returns title in an html element
 :
 : different html element whereas it is an analytic or a monographic title
 : @todo serialize the text properly for tei:hi, etc.
 :)
declare function getBibTitle($node, $options as map(*)) {
  for $title in $node/tei:title
  let $separator := '. '
  return if ($title[@level='a'])
    then (<span class="title">« {$title/text()} »</span>, $separator)
    else (<em class="title">{$title/text()}</em>, $separator)
};

declare function getEdition($node, $options as map(*)) {
 $node/tei:edition/text()
};

declare function getMeeting($node, $options as map(*)) {
  $node/tei:meeting/text()
};

declare function getImprint($node, $options as map(*)) {
  for $vol in $node/tei:biblScope[@type='vol']
  return if ($vol[following-sibling::tei:*]) then ($vol, ', ')
    else ($vol, '. '), 
  for $pubPlace in $node/tei:pubPlace
  return 
    if ($pubPlace) then ($pubPlace/text(), ' : ')
    else 's.l. :',
  for $publisher in $node/tei:publisher
  return 
    if ($publisher) then ($publisher/text(), ', ')
    else 's.p.',
  for $date in $node/tei:date
  return
    if ($date and $node/tei:biblScope[@type='pp']) then ($date/text(), ', ')
    else if ($date) then ($date/text(), '.')
      else 's.d.',
  for $page in $node/tei:biblScope[@type='pp']
  return
    if ($page) then ($page, '.')
    else '.'
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei titlePage
 : ~:~:~:~:~:~:~:~:~
 :)
declare function getTitlePage($node, $options as map(*)) {
  <div class="titlePage">{ passthru($node, map{ 'key': 1}) }</div>
};

declare function getDocTitle($node, $options as map(*)) {
  <header>{passthru($node, map{ 'key': 1})}</header>
};

declare function getTitlePart($node, $options as map(*)) {
  <h1>{passthru($node, map{ 'key': 1})}</h1>
};

declare function getByline($node, $options as map(*)) {
  <div class="byline">{passthru($node, map{ 'key': 1})}</div>
};

declare function getDocImprint($node, $options as map(*)) {
  <div class="docImprint">{passthru($node, map{ 'key': 1})}</div>
};

declare function getImprimatur($node, $options as map(*)) {
  <div class="imprimatur">{passthru($node, map{ 'key': 1})}</div>
};

declare function getDocDate($node, $options as map(*)) {
  <div class="docDate">{passthru($node, map{ 'key': 1})}</div>
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei biblio
 : ~:~:~:~:~:~:~:~:~
 :)

 declare function getBiblStruct($record as element(), $options as map(*)){
   switch ($record)
   case $record[tei:analytic] return getBiblJournalRef($record, $options)
   case $record[tei:monogr/tei:meeting] return getBiblMeetingRef($record, $options)
   default return getBiblMonogrRef($record, $options)
 };

 (: @todo lack details :)
 declare function getBiblJournalRef($record, $options as map(*)) {
  let $biblResp := getBiblResp($record, $options)
  let $biblJournalTitle := getBiblJournalTitle($record, $options)
  let $biblTitle := getBiblTitle($record, $options)
  let $biblEdition := getBiblEdition($record, $options)
  return <span>{
   (
       if (fn:count($biblResp)!=0) then fn:concat($biblResp, '. '),
       if (fn:count($biblJournalTitle)!=0) then $biblJournalTitle, '.',
       if (fn:count($biblTitle)!=0) then $biblTitle, '.',
       if (fn:count($biblEdition)!=0) then $biblEdition, '.'
   ),
   '.'
   }</span>
 };

 (: @todo :)
 declare function getBiblMeetingRef($record, $options as map(*)) {
   ''
 };
 (: @todo book chapter :)

 (:declare function getBiblMonogrRef($record, $options as map(*)) {
   (
     getBiblResp($record, $options),
     getBiblTitle($record, $options),
     getBiblEdition($record, $options)
   ) => fn:string-join('. ') || '.'
 };:)
 declare function getBiblMonogrRef($record, $options as map(*)) {
  let $biblResp := getBiblResp($record, $options)
  let $biblTitle := getBiblTitle($record, $options)
  let $biblEdition := getBiblEdition($record, $options)
  return <span>{
   (
     if (fn:count($biblResp)!=0) then fn:concat($biblResp, '. '),
     if (fn:count($biblTitle)!=0) then $biblTitle, '.',
     if (fn:count($biblEdition)!=0) then $biblEdition
   ),
   '.'
   }</span>
 };

 (:~
  : this function
  : @todo améliorer le traitement , et
  :)
 declare function getBiblResp($record, $options as map(*)) {
   $record/tei:monogr/tei:author ! getBiblAuthor(., $options)
   => fn:string-join(', ')
 };

 declare function getBiblAuthor($author, $options as map(*)) {
  $author/tei:persName/tei:forename || ' ' || $author/tei:persName/tei:surname
 };

 (: @todo passthru :)
 declare function getBiblTitle($record, $options as map(*)) {
   <em class="title">{$record/tei:monogr/tei:title => fn:string-join()}</em>
 };

 (: @todo passthru :)
 declare function getBiblJournalTitle($record, $options as map(*)) {
   <span class="analytic">{'« ', $record/tei:monogr/tei:title => fn:string-join(), ' »'}</span>
 };

 (: @todo passthru :)
 (: @todo replace concat with :)
 declare function getBiblEdition($record, $options as map(*)) {
   let $imprint := $record/tei:monogr/tei:imprint
   let $pubPlace := $imprint/tei:pubPlace => fn:string-join(', ')
   let $publisher := $imprint/tei:publisher => fn:string-join(', ')
   return (
     if ($pubPlace and $imprint/tei:date[.!='']) then ($pubPlace, ':') else if ($pubPlace) then $pubPlace,
     if ($publisher and $imprint/tei:date[.!='']) then fn:concat($publisher, ',') else if ($publisher) then $publisher,
     if ($imprint/tei:date[.!='']) then $imprint/tei:date => fn:string-join( ', ')
   )
   (:fn:concat(
   $imprint/tei:pubPlace => fn:string-join(', ') ! fn:concat(., ' : '),
   ' : ',
   $imprint/tei:publisher => fn:string-join(', '),
   ', ',
   $imprint/tei:date[1]
   ):)
 };

 declare function getBiblRefIdno($record, $options as map(*)) {
   'test'
 };