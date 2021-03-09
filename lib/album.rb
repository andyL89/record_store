class Album
  attr_reader :id #Our new save method will need reader methods.
  attr_accessor :name

  def initialize(attributes) # We've added id as a second parameter.
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)  # We've added code to handle the id.
  end

  def self.all
    returned_albums = DB.exec("SELECT * FROM albums;")
    albums = []
    returned_albums.each() do |album|
      name = album.fetch("name")
      id = album.fetch("id").to_i
      albums.push(Album.new({:name => name, :id => id}))
    end
    albums
  end

  def save
    result = DB.exec("INSERT INTO albums (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def ==(album_to_compare)
    self.name() == album_to_compare.name()
  end

  def self.clear
    DB.exec("DELETE FROM albums *;")
  end

  def self.find(id)
    album = DB.exec("SELECT * FROM albums WHERE id = #{id};").first
    name = album.fetch("name")
    id = album.fetch("id").to_i
    Album.new({:name => name, :id => id})
  end

  def update(attributes)
    if (attributes.has_key?(:name)) && (attributes.fetch(:name) != nil)
      @name = attributes.fetch(:name)
      DB.exec("UPDATE albums SET name = '#{@name}' WHERE id = #{@id};")
    elsif (attributes.has_key?(:artist_name)) && (attributes.fetch(:artist_name) != nil)
      artist_name = attributes.fetch(:artist_name)
      artist = DB.exec("SELECT * FROM artists WHERE lower(name)='#{artist_name.downcase}';").first
      if artist != nil
        DB.exec("INSERT INTO albums_artists (album_id, artist_id) VALUES (#{@id}, #{artist['id'].to_i});")
      end
    end
  end

  def artists
    artists = []
    results = DB.exec("SELECT artist_id FROM albums_artists WHERE album_id = #{@id};")
    results.each() do |result|
      artist_id = result.fetch("artist_id").to_i()
      artist = DB.exec("SELECT * FROM artists WHERE id = #{artist_id};")
      name = artist.first().fetch("name")
      artists.push(Artist.new({:name => name, :id => artist_id}))
    end
    artists
  end

  def delete
    DB.exec("DELETE FROM albums WHERE id = #{@id};")
    DB.exec("DELETE FROM songs WHERE album_id = #{@id};") # new code
  end

  def songs
    Song.find_by_album(self.id)
  end

  def self.sort
    returned_albums = DB.exec("SELECT * FROM albums ORDER BY name;")
    albums = []
    returned_albums.each() do |album|
      name = album.fetch("name")
      id = album.fetch("id").to_i
      albums.push(Album.new({:name => name, :id => id}))
    end
    albums
  end

end