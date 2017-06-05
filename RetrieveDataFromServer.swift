    
    ///////////////////////////////////////////////////////////////////////////////
    // Retrive data from API service
    // Normally, all required data needs to be included in Http address.
    // All variables also needs to be determined before call function retrieveDataFromServer()
    // 서버에서 API로 데이터 받아오기 & JSON Parsing
    // 일반적으로 API 문법에서 요구되는 내용들은 http 주소 안에 미리 포함되어 있어야 한다.
    // retrieveDataFromServer() 함수를 호출하기 전에 API 안에 포함되어야 할 변수들이 미리 셋팅되어 있어야 한다.
    ///////////////////////////////////////////////////////////////////////////////
    
    // container for JSON parsing finished
    // 파싱 완료 된 데이터들이 저장되는 컨테이너
    var festivalsAll: Array<Dictionary<String, String>> = []
    
    func retrieveDataFromServer() {
        
        // Your API Address, Key, etc
        // API 주소와 키 등. 문법에 맞게
        let str = "http://api.yoursite.com/api?ServiceKey= ... " as String
        
        // Sometimes below encoding required. Try if errors
        // 아래 구문 없이도 되는 사이트가 있고 없으면 안되는 사이트가 있다.
        // let strURL = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // Skip unwrapping if the Percent Encoding is not applied
        // 위의 퍼센트 인코딩이 필요 없으면 let strURLUW = strURL 로 언래핑 해 줄 필요 없다.
        // if let strURLUW = strURL,
        if let urlFromStrURLUW = URL(string: str) {
            
            // UW = UnWrapped
            let request = URLRequest(url: urlFromStrURLUW)
            
            // Utilize URLSession for background processing
            // URL 세션을 사용해서 백그라운드에서 작업이 되도록 한다
            let session = URLSession.shared
            
            // make dataTask of session object
            // URLSession 의 객체인 session 에 dataTask 객체를 생성하여  dataTask 에 할당한다
            let dataTask = session.dataTask(with: request, completionHandler: dataTaskCompletionHandler)
            
            // Start task if all preparation is settled.
            // 준비가 완료되면 작업을 시작시킨다.
            dataTask.resume()
        }
        
    }
    
    
    func dataTaskCompletionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        // If server return errors
        // error 가 수신되었으면 출력
        guard error == nil else {
            print("Handler got Error")
            return
        }
        
        // Check if data is received normally
        // data 수신 확인
        guard let receivedData = data else {
            print("Data receiving error")
            return
        }
        
        // Prepare container for serialized data
        // serialize 된 데이터를 담을 컨테이너를 만든다.
        var serializedDataContainer: [String : AnyObject] = [:]
        
        // Parsing received data
        // 수신된 JSON 데이터를 Parsing 한다.
        do {
            // Convert serialized data
            // binary data 를 변환 (serialize)
            guard let serializedData = try JSONSerialization.jsonObject(with: receivedData, options: []) as? [String : AnyObject] else {
                print("Error while serialize")
                return
            }
            // If serialization finished without error set it to container above
            // 데이터 serialization 이 제대로 되었다면 컨테이너에 담는다.
            serializedDataContainer = serializedData
            
            // print to console that retrieving data is compeleted
            // 콘솔에 Done 이라고 찍어 데이터 수신이 제대로 되었음을 알린다.
            print("Done")
            
        } catch {
            // if errors while do
            // do 문에서 에러가 발생하면 콘솔에 찍는다
            print("JSON data parsing error")
        }
        
        
        // find key word in serializedData. The key of below example is response
        // serializedData 에서 분리하고자 하는 키워드를 찾는다. 아래 예제는 response 이다.
        guard let dataFromResponse = serializedDataContainer["response"] as? [String: AnyObject] else {
            // if errors print it
            // 에러가 있다면 콘솔에 표시한다
            print("Error while extract RESPONSE from serializedData")
            return
        }
        
        // key word = body
        guard let dataFromBody = dataFromResponse["body"] as? [String: AnyObject] else {
            print("Error while extract BODY from dataFromResponse")
            return
        }
        
        // key word = items
        guard let dataFromItems = dataFromBody["items"] as? [String: AnyObject] else {
            print("Error while extract ITEMS from dataFromBody")
            return
        }
        
        // key word = item
        guard let parsedArrayPrev = dataFromItems["item"] as? Array<Dictionary<String, AnyObject>> else {
            print("Error while extract ITEM from dataFromItems")
            return
        }
        
        // initialize container
        // container 초기화
        self.festivalsAll = []
        
        // This case assume that received data is mixing with Int and String
        // The container festivalsAll is Array<Dictionary<String, String>> format so cannot accept Int
        // So convert ALL items to String
        // For every value in evers arrays, allocate key(string) and value(AnyObject) to tuple
        // And convert value to String() and store to temp container as Dictionary
        // If String task finished for a array, add it final container festivalsAll and go on next array for all arrays
        // 수신되는 데이터가 스트링과 인티저의 혼합형이라서 변수에 한 번에 담기지 않는다.
        // Array<Dictionary<String, String>> 이어야 하는데 Int 가 와서 오류!!
        // 매 배열 아이템마다, 매 아이템의 딕셔너리 데이터에 대해 키 밸류마다 값을 꺼내서 스트링으로 변환하여
        // 임시 딕셔너리에 저장하고 그 딕셔너리를 최종 배열에 append 한다.
        for item in parsedArrayPrev {
            var tempContainer: Dictionary<String, String> = [:]
            for (key, value) in item {
                tempContainer[key] = String(describing: value)
            }
            self.festivalsAll.append(tempContainer)
        }
        
        // request table view referesh to main queue
        // main queue 로 table view referesh 요청을 한다.
        DispatchQueue.main.async {
            // reload data to table
            // table view 에 데이터 반영
            self.tableViewOutlet.reloadData()
        }
        
    }
   
