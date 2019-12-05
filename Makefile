GOCMD = go
GOBUILD = $(GOCMD) build
GOCLEAN = $(GOCMD) clean
GOFMT = $(GOCMD) fmt

TARGET = cont8ner

build:
	$(GOBUILD) -o $(TARGET) -v

clean:
	$(GOCLEAN)
	rm -f $(TARGET)

format:
	$(GOFMT) ./...
