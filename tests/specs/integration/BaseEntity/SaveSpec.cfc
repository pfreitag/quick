component extends="tests.resources.ModuleIntegrationSpec" appMapping="/app" {

    function beforeAll() {
        super.beforeAll();
        var interceptorService = getWireBox().getInstance( dsl = "coldbox:interceptorService" );
        interceptorService.registerInterceptor( interceptorObject = this );
    }

    function run() {
        describe( "Save Spec", function() {
            describe( "normal saving", function() {
                it( "inserts the attributes as a new row if it has not been loaded", function() {
                    var newUser = getInstance( "User" );
                    newUser.setUsername( "new_user" );
                    newUser.setFirstName( "New" );
                    newUser.setLastName( "User" );
                    newUser.setPassword( hash( "password" ) );
                    var userRowsPreSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPreSave ).toHaveLength( 3 );
                    newUser.save();
                    var userRowsPostSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPostSave ).toHaveLength( 4 );
                    var newUserAgain = getInstance( "User" ).whereUsername( "new_user" ).firstOrFail();
                    expect( newUserAgain.getFirstName() ).toBe( "New" );
                    expect( newUserAgain.getLastName() ).toBe( "User" );
                } );
                it( "allow inserting of column where update=false in property", function() {
                    var newUser = getInstance( "User" );
                    newUser.setUsername( "new_user2" );
                    newUser.setFirstName( "New2" );
                    newUser.setLastName( "User2" );
                    newUser.setEmail( "test2@test.com" );
                    newUser.setPassword( hash( "password" ) );
                    var userRowsPreSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPreSave ).toHaveLength( 3 );
                    newUser.save();
                    var userRowsPostSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPostSave ).toHaveLength( 4 );
                    var newUserAgain = getInstance( "User" ).whereUsername( "new_user2" ).firstOrFail();
                    expect( newUserAgain.getFirstName() ).toBe( "New2" );
                    expect( newUserAgain.getLastName() ).toBe( "User2" );
                    expect( newUserAgain.getEmail() ).toBe( "test2@test.com" );
                } );


                it( "retrieves the generated key when saving a new record", function() {
                    var newUser = getInstance( "User" );
                    newUser.setUsername( "new_user" );
                    newUser.setFirstName( "New" );
                    newUser.setLastName( "User" );
                    newUser.setPassword( hash( "password" ) );
                    newUser.save();
                    expect( newUser.retrieveAttributesData() ).toHaveKey( "id" );
                } );

                it( "a saved entity is not dirty", function() {
                    var newUser = getInstance( "User" );
                    newUser.setUsername( "new_user" );
                    newUser.setFirstName( "New" );
                    newUser.setLastName( "User" );
                    newUser.setPassword( hash( "password" ) );
                    newUser.save();
                    expect( newUser.isDirty() ).toBeFalse();
                } );

                it( "updates the attributes of an existing row if it has been loaded", function() {
                    var existingUser = getInstance( "User" ).find( 1 );
                    existingUser.setUsername( "new_elpete_username" );
                    var userRowsPreSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPreSave ).toHaveLength( 3 );
                    existingUser.save();
                    var userRowsPostSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPostSave ).toHaveLength( 3 );
                } );

                it( "does not allow updating of column where update=false in property", function() {
                    var existingUser = getInstance( "User" ).find( 1 );
                    existingUser.setEmail( "test2@test.com" );
                    var userRowsPreSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPreSave ).toHaveLength( 3 );
                    existingUser.save();
                    var userRowsPostSave = queryExecute( "SELECT * FROM users" );
                    expect( userRowsPostSave ).toHaveLength( 3 );
                    expect( userRowsPostSave.email ).toBe( "" );
                } );

                it( "uses the type attribute if present for each column", function() {
                    structDelete( request, "saveSpecPreQBExecute" );

                    var newPhoneNumber = getInstance( "PhoneNumber" );
                    newPhoneNumber.setNumber( "+18018644200" );
                    newPhoneNumber.save();

                    expect( request ).toHaveKey( "saveSpecPreQBExecute" );
                    expect( request.saveSpecPreQBExecute ).toBeArray();
                    expect( request.saveSpecPreQBExecute ).toHaveLength( 1 );
                    expect( request.saveSpecPreQBExecute[ 1 ] ).toHaveKey( "bindings" );
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings ).toBeArray();
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings ).toHaveLength( 1 );
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings[ 1 ] ).toHaveKey( "value" );
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings[ 1 ].value ).toBe( "+18018644200" );
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings[ 1 ] ).toHaveKey( "cfsqltype" );
                    expect( request.saveSpecPreQBExecute[ 1 ].bindings[ 1 ].cfsqltype ).toBe( "CF_SQL_VARCHAR" );
                } );
            } );

            describe( "many-to-many relationship saving", function() {
                describe( "attach", function() {
                    it( "can attach an id to a relationship", function() {
                        var tag = getInstance( "Tag" );
                        tag.setName( "miscellaneous" );
                        tag.save();

                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );

                        post.tags().attach( tag.getId() );

                        post.refresh();

                        expect( post.getTags() ).toBeArray();
                        expect( post.getTags() ).toHaveLength( 3 );
                    } );

                    it( "attaches using the id if the entity is passed", function() {
                        var tag = getInstance( "Tag" );
                        tag.setName( "miscellaneous" );
                        tag.save();

                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );

                        post.tags().attach( tag );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 3 );
                    } );

                    it( "can attach multiple ids or entities at once", function() {
                        var tagA = getInstance( "Tag" );
                        tagA.setName( "miscellaneous" );
                        tagA.save();

                        var tagB = getInstance( "Tag" );
                        tagB.setName( "other" );
                        tagB.save();

                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );

                        post.tags().attach( [ tagA.getId(), tagB ] );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 4 );
                    } );
                } );

                describe( "detach", function() {
                    it( "can detach an id from a relationship", function() {
                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );

                        var tag = post.getTags().toArray()[ 1 ];

                        post.tags().detach( tag.getId() );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 1 );
                    } );

                    it( "detaches using the id if the entity is passed", function() {
                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );

                        var tag = post.getTags().toArray()[ 1 ];

                        post.tags().detach( tag );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 1 );
                    } );

                    it( "can detach multiple ids or entities at once", function() {
                        var post = getInstance( "Post" ).find( 1245 );

                        var tags = post.getTags().toArray();
                        expect( tags ).toBeArray();
                        expect( tags ).toHaveLength( 2 );

                        post.tags().detach( [ tags[ 1 ].getId(), tags[ 2 ] ] );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toBeEmpty();
                    } );
                } );

                describe( "sync", function() {
                    it( "sets the related ids equal to the list passed in", function() {
                        var newTagA = getInstance( "Tag" );
                        newTagA.setName( "miscellaneous" );
                        newTagA.save();

                        var newTagB = getInstance( "Tag" );
                        newTagB.setName( "other" );
                        newTagB.save();

                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );
                        var existingTags = post.getTags().toArray();

                        var tagsToSync = [ existingTags[ 1 ], newTagA.getId(), newTagB ];
                        var tagIds = [
                            existingTags[ 1 ].keyValue(),
                            newTagA.keyValue(),
                            newTagB.keyValue()
                        ];

                        post.tags().sync( [ existingTags[ 1 ], newTagA.getId(), newTagB ] );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 3 );
                        expect( post.getTags().map( function( tag ) { return tag.keyValue(); } ).toArray() ).toBe( tagIds );
                    } );

                    it( "sets the related ids equal to the list passed in using a relationship setter", function() {
                        var newTagA = getInstance( "Tag" );
                        newTagA.setName( "miscellaneous" );
                        newTagA.save();

                        var newTagB = getInstance( "Tag" );
                        newTagB.setName( "other" );
                        newTagB.save();

                        var post = getInstance( "Post" ).find( 1245 );

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 2 );
                        var existingTags = post.getTags().toArray();

                        var tagsToSync = [ existingTags[ 1 ], newTagA.getId(), newTagB ];
                        var tagIds = [
                            existingTags[ 1 ].keyValue(),
                            newTagA.keyValue(),
                            newTagB.keyValue()
                        ];

                        post.setTags( [ existingTags[ 1 ], newTagA.getId(), newTagB ] );

                        post.refresh();

                        expect( post.getTags().toArray() ).toBeArray();
                        expect( post.getTags().toArray() ).toHaveLength( 3 );
                        expect( post.getTags().map( function( tag ) { return tag.keyValue(); } ).toArray() ).toBe( tagIds );
                    } );
                } );
            } );
        } );
    }

    function preQBExecute( event, interceptData, buffer, rc, prc ) {
        param request.saveSpecPreQBExecute = [];
        arrayAppend( request.saveSpecPreQBExecute, duplicate( arguments.interceptData ) );
    }

}
