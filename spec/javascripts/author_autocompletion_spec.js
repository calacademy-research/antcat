describe("insertAuthor", function() {
  it("should do nothing if the input and author is blank", function() {
    expect(insertAuthor("", 0, "")).toEqual({string: "", position: 0});
  });

  it("should replace the string with the author if there are no semicolons", function() {
    expect(insertAuthor("mark", 0, "kate")).toEqual({string: "kate; mark", position: 6});
  });

  it("should insert the author after the preceding semicolon", function() {
    expect(insertAuthor("mark; kate; bert", 5, "paul")).toEqual({string: "mark; paul; kate; bert", position: 12});
  });

  it("should handle being in the first word", function() {
    expect(insertAuthor("mark; kate; bert", 1, "paul")).toEqual({string: "paul; ark; kate; bert", position: 6});
  });

  it("should handle being in the last word", function() {
    expect(insertAuthor("mark; kate; bert", 11, "paul")).toEqual({string: "mark; kate; paul; bert", position: 18});
  });
});

describe("extractAuthorSearchTerm", function() {
  it("should return nothing if there is nothing there", function() {
    expect(extractAuthorSearchTerm("", 0)).toEqual("");
  });
  it("should return nothing if nothing before the cursor", function() {
    expect(extractAuthorSearchTerm("mark", 0)).toEqual("");
  });
  it("should return text before the cursor", function() {
    expect(extractAuthorSearchTerm("mark", 4)).toEqual("mark");
  });
  it("should return part before the cursor", function() {
    expect(extractAuthorSearchTerm("mark", 1)).toEqual("m");
  });
  it("should return part between the cursor and the preceding semicolon", function() {
    expect(extractAuthorSearchTerm(";mark", 2)).toEqual("m");
  });
});
