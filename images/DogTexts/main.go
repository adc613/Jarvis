package main

import (
  "net/http"
  "net/url"
  "fmt"
  "strings"
  "os"
  "encoding/json"
)

type Response2 struct {
  Results []Person
}

type Person struct {
  Gender string
  Name Name
}

type Name struct {
  First string
  Last string
  Title string
}

type Response struct {
  Message string
}

type Dog struct {
  Url string
  Format string
  Id string
}

func main() {
  fmt.Printf("start\n")
  title, first, last := getName()
  pic := getADog()
  msg := "Hello Jamie, this is Jarvis Adam's, personal assistant. "
  msg += "Adam says goodnight and here's picture of " + title + ". " + first + " " + last
  msg += ". Sweet dreams!"
  sendText(msg, pic)

}

func sendText(args ...string) {
  msg := args[0]
  accountSid := "AC19dd69d986658313d0c871bdbf0c37de"
  authToken := os.Getenv("TWILIO")
  to := os.Getenv("TO_NUMBER")
  from := os.Getenv("TWILIO_NUMBER")
  urlStr := "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json"

  // Build out the data for our message
  v := url.Values{}
  v.Set("To", to)
  v.Set("From", from)
  v.Set("Body", msg)
  if(len(args) > 1) {
    v.Set("MediaUrl", args[1])
  }
  rb := *strings.NewReader(v.Encode())

  // Create client
  client := &http.Client{}

  req, _ := http.NewRequest("POST", urlStr, &rb)
  req.SetBasicAuth(accountSid, authToken)
  req.Header.Add("Accept", "application/json")
  req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

  // Make request
  resp, err := client.Do(req)
  if err != nil {
    fmt.Printf("fail")
  } else {
    fmt.Printf(resp.Status)
  }
}

func getADog() string {
  resp, err := http.Get("https://dog.ceo/api/breeds/image/random")
  if err != nil {
    fmt.Printf("fail")
  } else {
    fmt.Printf(resp.Status)

    defer resp.Body.Close()
    dog := Response{}
    json.NewDecoder(resp.Body).Decode(&dog)
    return dog.Message
  }
  return ""
}

func getName() (string, string, string) {
  resp, err := http.Get("https://randomuser.me/api?nat=us")
  if err != nil {
    return "Ms.", "Jamie", "Yu"
  } else {
    defer resp.Body.Close()

    person := Response2{}
    json.NewDecoder(resp.Body).Decode(&person)
    if(len(person.Results) > 0) {
      title := person.Results[0].Name.Title
      first := person.Results[0].Name.First
      last := person.Results[0].Name.Last
      return title, first, last
    } else {
      return "Mr.", "Adam", "Collins"
    }
  }
}
