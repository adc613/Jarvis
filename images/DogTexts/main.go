package main

import (
  "bytes"
  "text/template"
  "flag"
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
  fmt.Println("start")

  title, first, last := getName()
  name := Name{First:first, Last:last, Title:title}

  dMsg := "Hello Jamie, this is Jarvis Adam's, personal assistant. "
  dMsg += "Adam says goodnight and here's picture of " + title + ". " + first + " " + last
  dMsg += ". Sweet dreams!"

  msg := flag.String("m", dMsg, "The text message being sent to the user")
  tmplMsg := flag.String("template", "", "The text message being sent to the user")
  debug := flag.Bool("debug", false, "Doesn't send the message")
  to := flag.String("to", "+18475626149", "Doesn't send the message")
  noPic := flag.Bool("no-pic", false, "Don't add a pic")

  flag.Parse()

  pic := ""
  if !*noPic {
    pic =  getADog()
  }

  sendText(*msg, *tmplMsg, name, pic, *to, *debug)
}

func sendText(msg string, tmplMsg string, name Name, pic string, to string, debug bool) {
  accountSid := "AC19dd69d986658313d0c871bdbf0c37de"
  authToken := os.Getenv("TWILIO")
  from := os.Getenv("TWILIO_NUMBER")

  fmt.Println("auth: ", authToken)
  fmt.Println("to: ", to)
  fmt.Println("from: ", from)
  fmt.Println("pic: ", pic)

  urlStr := "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json"
  sendMsg := msg
  if tmplMsg != "" {
    tmpl, err := template.New("message").Parse(tmplMsg)
    if err == nil {
      var tpl bytes.Buffer
      err = tmpl.Execute(&tpl, name)
      if err == nil {
        sendMsg = tpl.String()
      }
    }
  }

  // Build out the data for our message
  v := url.Values{}
  v.Set("To", to)
  v.Set("From", from)
  v.Set("Body", sendMsg)
  if pic != "" {
    v.Set("MediaUrl", pic)
  }
  rb := *strings.NewReader(v.Encode())

  // Create client
  client := &http.Client{}

  req, _ := http.NewRequest("POST", urlStr, &rb)
  req.SetBasicAuth(accountSid, authToken)
  req.Header.Add("Accept", "application/json")
  req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

  fmt.Printf("response:\n")
  // Make request


  if !debug {
    resp, err := client.Do(req)
    if err != nil {
      fmt.Printf("fail")
    } else {
      fmt.Printf(resp.Status)
    }
  } else {
    fmt.Printf("\nMessage: \n\n")
    fmt.Printf(sendMsg)
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
