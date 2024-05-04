using System;
using System.Net.Sockets;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using System.Net;
using System.IO;

public class Server : MonoBehaviour {
  //General Init
  private List<ServerClient> clients;
  private List<int> disconnectIndex;

  //Camera Variables
  private GameObject MainCam;
  RenderTexture CameraRender;
  byte[] EncodedPng;
  int Height;
  int Width;
  bool ScreenshotDone;

  /////////////////////////////////////////////////////////////////////////////
  // main GUI components that appear for the user.
  /////////////////////////////////////////////////////////////////////////////
  [Header("Server Settings")]
  public int Port = 55001;
  private TcpListener server;
  private bool serverStarted;

  //[Header("Game Object Settings")]
  public string ObjectName;
  //public Vector2 Resolution = new Vector2();
  /////////////////////////////////////////////////////////////////////////////
  
  // Use this for initialization
  void Start () {
    clients = new List<ServerClient>();
    disconnectIndex = new List<int>();

    try {
      server = new TcpListener(IPAddress.Any, Port);
      server.Start();

      Startlistening();
      serverStarted = true;
      Debug.Log("Server has started on port:" + Port.ToString());
    }
    catch (Exception e) {
      Debug.Log("Socket Error " + e.Message);
    }

    InvokeRepeating("UpdateLoop", 0f, 0.003f);  
  }

  private void UpdateLoop(){
    if(this.MainCam == null)
      this.MainCam = GameObject.FindGameObjectWithTag("MainCamera");

    if (!serverStarted)
      return;
    if(clients.Count == 0)
      return;

    for(int c = 0; c < clients.Count; c++ ) {
      //Check if clients are connected
      if(!isConnected(clients[c].tcp)) {
        clients[c].tcp.Close();
        disconnectIndex.Add(c);
        Debug.Log(clients[c].clientName + " has disconnected from the server");
        continue;
      }
      // Check for data from client
      else {
        float[] myFloat = new float[9];
        NetworkStream s = clients[c].tcp.GetStream();
        if (s.DataAvailable) {
          byte[] RecievedString = new byte[sizeof(float)*9];

          if (RecievedString != null){
            s.Read(RecievedString, 0, sizeof(float)*9);
            myFloat = ConvertBytes2Float(RecievedString);

            moveCamera(myFloat);
                      
            StartCoroutine(SendCamCapture(clients[c], MainCam.GetComponent<Camera>(), myFloat[0].ToString(), myFloat[1].ToString()));
          }
          s.Flush();
        }  
      }
    }

    //Clean up Disconnected Clients
    for(int i = 0; i < disconnectIndex.Count; i++) {
      clients.RemoveAt(disconnectIndex[i]);
    }
    disconnectIndex.Clear();
  }

  private byte[] ConvertFloat2Bytes(float[] FloatArray){
    var byteArray = new byte[FloatArray.Length * sizeof(float)];
    Buffer.BlockCopy(FloatArray, 0, byteArray, 0, byteArray.Length);
    return byteArray;
  }

  private float[] ConvertBytes2Float(byte[] byteArray){
    var floatArray = new float[byteArray.Length / sizeof(float)];
    Buffer.BlockCopy(byteArray, 0, floatArray, 0, byteArray.Length);
    return floatArray;
  }

  //Checks if client is connected
  private bool isConnected(TcpClient c){
    try {
      if(c != null && c.Client != null && c.Client.Connected){ //Makes sure the client is connected
        if(c.Client.Poll(0, SelectMode.SelectRead)){         //Polls the Client for activity
          return !(c.Client.Receive(new byte[1], SocketFlags.Peek) == 0); //Checks for response
        }
        return true;
      }
      else
        return false;
    }
    catch {
      return false;
    }
  }
  
  //Begins connection with client
  private void AcceptServerClient(IAsyncResult ar){
    TcpListener listener = (TcpListener)ar.AsyncState;
    ServerClient NewClient = new ServerClient(listener.EndAcceptTcpClient(ar), null);
    Debug.Log("Someone has connected");
    clients.Add(NewClient);
    Startlistening();
  }

  //Starts listening on server socket
  private void Startlistening(){
    server.BeginAcceptTcpClient(AcceptServerClient, server);
  }

  //Try to close all the connections gracefully
  void OnApplicationQuit(){
    for (int i = 0; i < clients.Count; i++){
      try{
        clients[i].tcp.GetStream().Close();
        clients[i].tcp.Close();
      }
      catch { }
    }
    Debug.Log("Connections Closed");
  }

  //Sends out data
  public void OutgoingData(ServerClient c, byte[] data){
    NetworkStream ClientStream = c.tcp.GetStream();
    try{
      ClientStream.Write(data, 0, data.Length);
    }
    catch (Exception e) {
      Debug.LogError("Could not write to client.\n Error:" + e);
    }
  }

  // Matlab used NED right-handed coordinate system
  // +x forward [optical axis]
  // +y right
  // +z down

  // Unity uses a wild left-handed coordinate system
  // +x right
  // +y up
  // +z forward [optical axis]
  
  //               matlab    unity
  // forward         x        z
  // right           y        x
  // down            z        -y
  
  private void moveCamera(float[] pose){
    // x,y,z,yaw[z],pitch[y],roll[x]
    float x_trans = pose[2];
    float y_trans = pose[3];
    float z_trans = pose[4];
    float z_rot = pose[5];
    float y_rot = pose[6];
    float x_rot = pose[7];
    float obj = pose[8];

    ObjectName = (obj == 1) ? "cam" : "TennisBall";

    GameObject ClientObj = GameObject.Find(ObjectName);
    
	Debug.Log("hello:" + x_trans);
    //Vector3 matlabTranslate = new Vector3(y_trans, -z_trans, x_trans);
	//Vector3 matlabTranslate = new Vector3(x_trans, y_trans, z_trans);
    // perform translation
    //ClientObj.transform.position = transform.TransformVector(matlabTranslate);
    
	//ClientObj.transform.position = ClientObj.transform.position + new Vector3(x_trans, y_trans, z_trans);
    ClientObj.transform.position = new Vector3(x_trans, y_trans, z_trans);

	
    // perform rotation in yaw, pitch, roll order while converting to left hand coordinate system.
    ClientObj.transform.rotation = Quaternion.AngleAxis(z_rot, Vector3.up) *       // yaw [z]
                                   Quaternion.AngleAxis(y_rot, Vector3.right)*    // pitch [y]
                                   Quaternion.AngleAxis(x_rot, Vector3.forward);  // roll [x]
  }
  
  //Organizes and Sends Picture
  IEnumerator SendCamCapture(ServerClient c, Camera CameraSelect, string Width, string Height){
    CaptureImage(CameraSelect, int.Parse(Width), int.Parse(Height));
    while (!this.CaptureDone()){
      yield return null;
    } 
    OutgoingData(c, this.ReturnCaptureBytes());
    Debug.Log("Captured Image");
  }

  IEnumerator GetRender(Camera cam){
    this.CameraRender = new RenderTexture(this.Width, this.Height, 16);
    cam.enabled = true;
    cam.targetTexture = CameraRender;
    Texture2D tempTex = new Texture2D(CameraRender.width, CameraRender.height, TextureFormat.RGB24, false);
    cam.Render();
    RenderTexture.active = CameraRender;//Sets the Render
    tempTex.ReadPixels(new Rect(0, 0, CameraRender.width, CameraRender.height), 0, 0);
    tempTex.Apply();
    EncodedPng = tempTex.GetRawTextureData();
    Destroy(tempTex);
    yield return null;
    CameraRender.Release();
    cam.targetTexture = null;
    ScreenshotDone = true;
  }

  public void CaptureImage(Camera SelectedCamera, int UsrWidth, int UsrHeight){
    ScreenshotDone = false;
    this.Width = UsrWidth;
    this.Height = UsrHeight;

    if (SelectedCamera != null){
        StartCoroutine(GetRender(SelectedCamera));
    }
  }

  public int GetWidth(){
    return this.Width;
  }

  public int GetHeight(){
    return this.Height;
  }

  public bool CaptureDone(){
    return ScreenshotDone;
  }

  public byte[] ReturnCaptureBytes(){
    return EncodedPng;
  }

  IEnumerator SerializeCapture(ServerClient c, byte[] PixelData, int Width, int Length){
    OutgoingData(c, PixelData);
    yield return null;
  }
}

public class ServerClient {
  public TcpClient tcp;
  public string clientName;
  public List<GameObject> ClientObj;

  public ServerClient(TcpClient clientSocket, string Name) {
    clientName = Name;
    tcp = clientSocket;
    ClientObj = new List<GameObject>();
  }
}