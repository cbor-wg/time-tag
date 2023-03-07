kdrfc -c draft-ietf-cbor-time-tag.md
xmlstarlet sel -T -t -v '//sourcecode[@type="cddl" and not(@name)]' draft-ietf-cbor-time-tag.xml > draft-ietf-cbor-time-tag-extracted.cddl.new
if cmp -s draft-ietf-cbor-time-tag-extracted.cddl.new draft-ietf-cbor-time-tag-extracted.cddl
then
   rm draft-ietf-cbor-time-tag-extracted.cddl.new
else
   mv -fv draft-ietf-cbor-time-tag-extracted.cddl.new draft-ietf-cbor-time-tag-extracted.cddl
fi
